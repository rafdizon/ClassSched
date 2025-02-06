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
    required fName, 
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
    required String instructorNo, 
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
        
        final sectionIDResp = await database.from('section').select('id').eq('year_level', year).eq('course_id', courseID).single();
        final sectionID = sectionIDResp['id'];
        if(sectionID != null) {
          await database.from('student')
          .insert({
            'first_name' : fName,
            'middle_name' : mName,
            'last_name' : lName,
            'student_no' : instructorNo,
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

  // read

  Future<List<dynamic>> getStudents() async {
    final students = await database
    .from('student')
    .select('id, student_no, first_name, middle_name, last_name, section(year_level, course(name)), is_regular, email, sex');
    
    return students;
  }

  Future<List<dynamic>> getCourses() async {
    final courses = await database.from('course').select();
    return courses;
  }

  Future<List<dynamic>> getinstructors() async {
    final instructors = await database
    .from('instructor')
    .select();

    return instructors;
  }

  // update

  // delete
  Future deleteUser({required int id, required String email}) async {
    try {
      //final users = await database.auth.admin.listUsers();
      //final user = users.firstWhere((user) => user.email == email, orElse: null);
      //final responseFromAuth = await database.auth.admin.deleteUser(user.id);
      final responseFromTable = await database.from('student').delete().eq('id', id);

      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }
}