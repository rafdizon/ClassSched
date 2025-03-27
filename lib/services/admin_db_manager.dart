import 'package:class_sched/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        final sectionIDResp = await database.from('section').select('id').eq('year_level', year).eq('course_id', courseID).single();
        final sectionID = sectionIDResp['id'];
        
        if(sectionID != null) {
          final studentInsertResponse = await database.from('student')
          .insert({
            'first_name' : fName,
            'middle_name' : mName,
            'last_name' : lName,
            'student_no' : studentNo,
            'email' : email,
            'sex' : sex,
            'is_regular' : isRegular,
            'section_id' : sectionID,
          }).select().single();

          final newStudentId = studentInsertResponse['id'];

          if(isRegular) {
            final schedResponse = await database.from('schedule_time').select('id').eq('section_id', sectionID);

            if(schedResponse.isNotEmpty) {
              for(var sched in schedResponse) {
                await database.from('student_schedule').insert({
                  'student_id' : newStudentId,
                  'schedule_time_id' : sched['id']
                });
              }
            }
          }
          else {
            final schedResponse = await database.from('schedule_time').select('id').eq('section_id', sectionID);

            if(schedResponse.isNotEmpty) {
              for(var sched in schedResponse) {
                await database.from('student_schedule_irregular').insert({
                  'student_id' : newStudentId,
                  'schedule_time_id' : sched['id']
                });
              }
            }
          }
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

  Future addScheduleSection({
    required String startTime,
    required String endTime,
    required int cycleId,
    required int curriculumId, 
    required int sectionId,
    required int instructorId,
    required List<String> days
  }) async {
    try {
      final schedResponse = await database.from('schedule_time')
      .insert({
        'start_time' : startTime,
        'end_time' : endTime,
        'cycle_id' : cycleId,
        'curriculum_id' : curriculumId,
        'section_id' : sectionId,
        'instructor_id' : instructorId,
        'days' : days
      }).select().single();

      final schedTimeId = schedResponse['id'];

      final studentResponse = await database
        .from('student')
        .select('id')
        .eq('section_id', sectionId)
        .eq('is_regular', true);

      final irregStudentResponse = await database
        .from('student')
        .select('id')
        .eq('section_id', sectionId)
        .eq('is_regular', false);

      final instructorResponse = await database
        .from('instructor')
        .select('id')
        .eq('id', instructorId);

      for ( var student in studentResponse) {
        await database.from('student_schedule').insert({
          'student_id' : student['id'],
          'schedule_time_id' : schedTimeId
        });
      }

      for ( var student in irregStudentResponse) {
        await database.from('student_schedule_irregular').insert({
          'student_id' : student['id'],
          'schedule_time_id' : schedTimeId
        });
      }
      for ( var instructor in instructorResponse) {
        await database.from('instructor_schedule').insert({
          'instructor_id' : instructor['id'],
          'schedule_time_id' : schedTimeId
        });
      }
      return null;
    } on Exception catch(e) {
      return e.toString();
    }
  }
  // read
  
  Future<Map<int, dynamic>> fetchSectionData() async {
    final sectionData = await Supabase.instance.client
        .from('section')
        .select('id, year_level, course(id, name, major)');

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
  Future getSections({required int courseId}) async {
    final sections = await database
    .from('section')
    .select('id, course(id, name, major, short_form), year_level')
    .eq('course_id', courseId);

    return sections;
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
  Future getCurriculum({required int courseId, int yearLevel = 0}) async {
    PostgrestList curriculum;
    if(yearLevel == 0) {
      curriculum = await database.from('curriculum')
      .select('id, subject(id, name, code, units, is_general_subject), year_level, semester_no')
      .eq('course_id', courseId).order('year_level', ascending: true);
    }
    else {
      curriculum = await database.from('curriculum')
      .select('id, subject(id, name, code, units, is_general_subject), year_level, semester_no')
      .eq('course_id', courseId)
      .eq('year_level', yearLevel).order('semester_no', ascending: true);
    }
    return curriculum;
  }

  Future getCurriculumBySem({required int courseId, required int semNo, int yearLevel = 0}) async {

    final curriculum = await database.from('curriculum')
      .select('id, subject(id, name, code, units, is_general_subject), year_level, semester_no')
      .eq('course_id', courseId)
      .eq('year_level', yearLevel)
      .eq('semester_no', semNo)
      .order('semester_no', ascending: true);

    return curriculum;
  }

  Future<List<Map<String, dynamic>>> getCycles() async {
    final cycles = await database.from('cycle')
    .select('id, cycle_no, start_date, end_date, semester(id, number, academic_year(academic_year, is_active))')
    .eq('semester.academic_year.is_active', true)
    .order('cycle_no', ascending: true);

    return cycles;
  }

  Future getSchedulesForSection({required int sectionId, required int semNo}) async {
    final sched = await database.from('schedule_time')
    .select('id, start_time, end_time, days, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year, academic_year(id, is_active, academic_year))), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level)')
    .eq('cycle.semester.number', semNo)
    .eq('cycle.semester.academic_year.is_active', true)
    .eq('section_id', sectionId);

    return sched;
  }

  Future getSchedulesForStudent({required int studentId}) async {
    final studentScheds = await database.from('student_schedule')
    .select('id, student(id, student_no, first_name, middle_name, last_name, email, is_regular, section(id, year_level, course(id, name, major, short_form))), schedule_time(id, start_time, end_time, days, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year, academic_year(id, is_active, academic_year))), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level))')
    .eq('schedule_time.cycle.semester.academic_year.is_active', true)
    .eq('student_id', studentId);

    Logger().i(studentScheds);
    return studentScheds;
  }

  Future getSchedulesForIrregStudent({required int studentId}) async {
    final studentScheds = await database.from('student_schedule_irregular')
    .select('id, student(id, student_no, first_name, middle_name, last_name, email, is_regular, section(id, year_level, course(id, name, major, short_form))), schedule_time(id, start_time, end_time, days, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year, academic_year(id, is_active, academic_year))), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level))')
    .eq('schedule_time.cycle.semester.academic_year.is_active', true)
    .eq('student_id', studentId);

    return studentScheds;
  }

  Future getNotifications() async {
    final notifs = await database.from('report')
    .select('id, header, body, is_opened, student(id, first_name, middle_name, last_name, email, student_no, is_regular), instructor(id, first_name, middle_name, last_name, email, is_full_time), created_at')
    .order('created_at');
    
    return notifs;
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

  Future updateScheduleSection({
    required int schedId,
    required String startTime,
    required String endTime,
    required int cycleId,
    required int curriculumId, 
    required int sectionId,
    required int instructorId,
    required List<String> days,
  }) async {
    try {
      // Update the schedule_time row based on curriculum and section identifiers.
      final updatedResponse = await database
        .from('schedule_time')
        .update({
          'start_time': startTime,
          'end_time': endTime,
          'cycle_id': cycleId,
          'instructor_id': instructorId,
          'days': days,
        })
        .eq('id', schedId)
        .select()
        .single();
        
      return null;
    } on Exception catch(e) {
      return e.toString();
    }
  }

  Future updateCycle({required int id, required String cycleNo, required String startDate, required String endDate}) async {
    await database.from('cycle')
    .update({
      'cycle_no' : cycleNo,
      'start_date' : startDate,
      'end_date' : endDate
    }).eq('id', id);
  }

  Future markNotifRead({required int id}) async {
    await database.from('report').update({'is_opened' : true}).eq('id', id);
  }

  // delete
  Future deleteUser({required int id, required String email, required bool isStudent}) async {
    try {
      try {
        await database.functions.invoke(
          'delete-user',
          body: {'email': email},
        );
      } catch (e) {
        //
      }
      
      if (isStudent) {
        await database.from('student').delete().eq('id', id);
      } else {
        await database.from('instructor').delete().eq('id', id);
      }
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
  Future deleteScheduleSection({required int id}) async {
    try {
      final response = await database.from('schedule_time')
        .delete()
        .eq('id', id);
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future moveAYtoHistory() async {
    try{
      final acadYear = await database.from('academic_year').select().eq('is_active', true).single();
      RegExp regExp = RegExp(r'(\d+)\s*to\s*(\d+)');
      Match? match = regExp.firstMatch(acadYear['academic_year'].toString());
      
      if (match != null) {
        int firstYear = int.parse(match.group(1)!);
        int secondYear = int.parse(match.group(2)!);
        
        firstYear += 1;
        secondYear += 1;
        
        String newYear = "$firstYear to $secondYear";
        await database.from('academic_year').update({'is_active' : false}).eq('is_active', true);
        await database.from('academic_year').insert({
          'academic_year' : newYear,
          'is_active' : true
        });

        final newAcadYear = await database.from('academic_year').select().eq('is_active', true).single();
        DateTime now = DateTime.now();
  
        String formattedDate = DateFormat('yyyy-MM-dd').format(now);

        await database.from('semester').insert([
          {
            'start_date' : formattedDate,
            'end_date' : formattedDate,
            'academic_year' : newAcadYear['academic_year'],
            'academic_year_id' : newAcadYear['id'],
            'number' : 1
          },
          {
            'start_date' : formattedDate,
            'end_date' : formattedDate,
            'academic_year' : newAcadYear['academic_year'],
            'academic_year_id' : newAcadYear['id'],
            'number' : 2
          },
          {
            'start_date' : formattedDate,
            'end_date' : formattedDate,
            'academic_year' : newAcadYear['academic_year'],
            'academic_year_id' : newAcadYear['id'],
            'number' : 3
          },
        ]);
        return null;
      }
      else {
        return 'Unsuccessful';
      }
    } on Exception catch (e) {
      return e.toString();
    }
  }
}