import 'package:class_sched/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

var logger = Logger();
class AdminDBManager {
  final database = Supabase.instance.client;
  final authService = AuthService();

  //create

  Future registerStudent({
    required String fName, 
    String? mName, 
    required String lName, 
    required String studentNo, 
    required String email, 
    required String pw,
    required int year,
    required int courseID,
    String? sex,
    required bool isRegular,
    required BuildContext context
    }) async {
      try {
        await authService.signUpWithEmailAndPassword(email, pw);
        logger.d('Year and course_id: ${year} and ${courseID}'); 
        final sectionIDResp = await database.from('section').select('id').eq('year_level', year).eq('course_id', courseID).single();
        final sectionID = sectionIDResp['id'];
        
        if(sectionID != null) {
          await database.from('student')
          .insert({
            'first_name' : fName,
            'middle_name' : mName,
            'last_name' : lName,
            'student_no' : studentNo,
            'email' : email,
            'sex' : sex,
            'is_regular' : isRegular,
            'section_id' : sectionID,
          });
        }
        return null;
      } on Exception catch (e) {
        logger.e(e);
        return e.toString();
      }
  }

  Future registerInstructor({
    required fName, 
    String? mName, 
    required String lName,
    required String email, 
    required String pw,
    String? sex,
    required bool isFullTime,
    required BuildContext context
    }) async {
      try {
        await authService.signUpWithEmailAndPassword(email, pw);
        await database.from('instructor')
        .insert({
          'first_name' : fName,
          'middle_name' : mName,
          'last_name' : lName,
          'email' : email,
          'sex' : sex,
          'is_full_time' : isFullTime,
          });
        return null;
      } on Exception catch (e) {
        logger.e(e);
        return e.toString();
      }
  }

  Future addCourse({
    required name,
    required level,
    String? major,
    required shortForm
  }) async {
    try {
      await database.from('course')
        .insert(
          {
          'name' : name,
          'major' : major,
          'level' : level,
          'short_form' : shortForm
          }
        );
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future addCycle({
    required semId, 
    required cycleNo,
    required startDate,
    required endDate,
    }) async {
      try {
        await database.from('cycle').insert({
          'cycle_no' : cycleNo,
          'start_date' : startDate,
          'end_date' : endDate,
          'semester_id' : semId,
        });
        return null;
      } on Exception catch (e) {
        return e.toString();
      }
  }

  // read
  
  Future<Map<int, dynamic>> fetchSectionData() async {
    final sectionData = await Supabase.instance.client
        .from('section')
        .select('id, year_level, course(id, name)');

    return { for (var s in sectionData) s['id']: s };
  }

  Future<Map<int, dynamic>> fetchAcadYearData({bool? isCurrent = false}) async {

    final acadYearData = await Supabase.instance.client
    .from('academic_year')
    .select()
    .eq('is_active', isCurrent! ? true : false);

    return { for(var a in acadYearData) a['id'] : a };
  }
 

  Future<List<dynamic>> getStudents() async {
    final students = await database
    .from('student')
    .select('id, student_no, first_name, middle_name, last_name, section(year_level, course(id, name)), is_regular, email, sex');
    
    return students;
  }

  Future<List<dynamic>> getCourses() async {
    final courses = await database.from('course').select().neq('id', 0);
    return courses;
  }

  Future<List<dynamic>> getinstructors() async {
    final instructors = await database
    .from('instructor')
    .select();

    return instructors;
  }

  // update
  Future editStudent({
    required int id, 
    required String fName, 
    String? mName, 
    required String lName,
    required int year,
    required int courseID,
    String? sex,
    required bool isRegular,
    required BuildContext context
  }) async {
    try {
      final sectionIDResp = await database.from('section').select('id').eq('year_level', year).eq('course_id', courseID).single();
      final sectionID = sectionIDResp['id'];
      if(sectionID != null) {
        await database
        .from('student')
        .update({
          'first_name' : fName,
          'middle_name' : mName,
          'last_name' : lName,
          'sex' : sex,
          'is_regular' : isRegular,
          'section_id' : sectionID,
        }).eq('id', id);
      }
      return null;
    } on Exception catch (e) {
      logger.e(e);
      return e.toString();
    }
  }

  Future editInstructor({
    required int id, 
    required String fName, 
    String? mName, 
    required String lName,
    String? sex,
    required bool isFullTime,
    required BuildContext context
  }) async {
    try {
      await database
      .from('instructor')
      .update({
        'first_name' : fName,
        'middle_name' : mName,
        'last_name' : lName,
        'sex' : sex,
        'is_full_time' : isFullTime,
      }).eq('id', id);

      return null;
    } on Exception catch (e) {
      logger.e(e);
      return e.toString();
    }
  }

  // delete
  Future deleteUser({required int id, required String email, required bool isStudent}) async {
    try {
      final responseFromFunc = await database.functions.invoke(
      'delete-user',
      body: {'email': email},
    );
      if(isStudent) {
        final responseFromTable = await database.from('student').delete().eq('id', id);
      }
      else {
        final responseFromTable = await database.from('instructor').delete().eq('id', id);
      }

      //logger.d(responseFromFunc);
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future deleteCourse({required id}) async {
    try {
      await database.from('course').delete().inFilter('id', id);
      return null;
    }
    on Exception catch (e) {
      return e.toString();
    }
  }

  Future deleteCycle({required id}) async {
    try {
      await database.from('cycle').delete().eq('id', id);
      return null;
    }
    on Exception catch (e) {
      return e.toString();
    }
  }

    Future deleteSubject({required id}) async {
    try {
      await database.from('subject').delete().inFilter('id', id);
      return null;
    }
    on Exception catch (e) {
      return e.toString();
    }
  }
}