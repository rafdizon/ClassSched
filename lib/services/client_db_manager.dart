import 'package:class_sched/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientDBManager {
  final logger = Logger();
  final database = Supabase.instance.client;
  final authService = AuthService();
  
  Future<bool> isUserStudent() async {
    final user = database.auth.currentUser;
    if (user == null) return false;

    final response = await database
      .from('student')
      .select()
      .eq('email', user.email!)
      .count(CountOption.exact);

    return (response.count ?? 0) > 0;
  }

  Future<Map<String, dynamic>?> getCurrentStudentInfo() async {
    final user = database.auth.currentUser;
    if (user == null) return null;

    final response = await database
        .from('student')
        .select('id, first_name, middle_name, last_name, student_no, email, sex, is_regular, section(course(name, major, short_form), year_level)')
        .eq('email', user.email!)
        .maybeSingle();
    
    return response;
  }
  Future<Map<String, dynamic>?> getCurrentInstructorInfo() async {
    final user = database.auth.currentUser;
    if (user == null) return null;

    final response = await database
        .from('instructor')
        .select('id, first_name, middle_name, last_name, email, sex, is_full_time')
        .eq('email', user.email!)
        .maybeSingle();
    
    return response;
  }

  Future<List<Map<String, dynamic>>?> getCurrentStudentSched() async {
    final user = database.auth.currentUser;
    if (user == null) return null;
    final userData = await getCurrentStudentInfo();

    final userStatus = userData?['is_regular'] as bool;

    List<Map<String, dynamic>> response;
    if(userStatus) {
      response = await database
        .from('student_schedule')
        .select('id, student(id, email, student_no), schedule_time(id, days, start_time, end_time, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year, academic_year(id, is_active, academic_year))), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level))')
        .eq('schedule_time.cycle.semester.academic_year.is_active', true)
        .eq('student.id', userData?['id']!)
        .not('student', 'is', null);
    } else {
      response = await database
        .from('student_schedule_irregular')
        .select('id, student(id, email, student_no), schedule_time(id, days, start_time, end_time, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year, academic_year(id, is_active, academic_year))), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level))')
        .eq('schedule_time.cycle.semester.academic_year.is_active', true)
        .eq('student.id', userData?['id']!)
        .not('student', 'is', null);
    }
    Logger().i(response);
    return response;
  }

   Future<List<Map<String, dynamic>>?> getCurrentInstructorSched() async {
      final user = database.auth.currentUser;
      if (user == null) return null;
      
      final userData = await getCurrentInstructorInfo();
      
      final response = await database.from('instructor_schedule')
      .select('id, instructor(id, email), schedule_time(id, days, start_time, end_time, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year, academic_year(id, is_active, academic_year))), section(id, course(id, name, short_form), year_level))')
      .eq('schedule_time.cycle.semester.academic_year.is_active', true)
      .not('schedule_time.cycle.semester.academic_year', 'is', null)
      .eq('instructor.email', user.email!)
      .not('instructor', 'is', null);

      return response;
   }

  Future<Map<String, dynamic>> getScheduleTime({required int id}) async {
    final response = await database
    .from('schedule_time')
    .select('id, days, start_time, end_time, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year)), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level)')
    .eq('id', id).maybeSingle() as Map<String, dynamic>;

    return response;
  }

  Future<List<Map<String, dynamic>>> getNotifs() async {
    bool isStudent = await isUserStudent();
    
    Logger().d(isStudent);
    List<Map<String, dynamic>>? response;

    if(isStudent) {
      final studentInfo = await getCurrentStudentInfo();
      if (studentInfo == null) {
        throw Exception("Student record not found");
      }
      final studentId = studentInfo['id'];

      response = await database.from('notifications').select(
        'id, created_at, student_id, report(id, status, header, body, created_at)'
      ).not('student_id', 'is', null).eq('student_id', studentId).order('created_at');
    }
    else {
      final instructorInfo = await getCurrentInstructorInfo();
      if (instructorInfo == null) {
        throw Exception("instructor record not found");
      }
      final instructorId = instructorInfo['id'];

      response = await database.from('notifications').select(
        'id, created_at, instructor_id, report(id, status, header, body, created_at)'
      ).eq('instructor_id', instructorId).not('instructor_id', 'is', null).order('created_at');
    }
    Logger().d(response);
    return response ?? [];
  }
  Future<int> countNotifs() async {
    bool isStudent = await isUserStudent();
    
    int response;

    if(isStudent) {
      final studentInfo = await getCurrentStudentInfo();
      if (studentInfo == null) {
        throw Exception("Student record not found");
      }
      final studentId = studentInfo['id'];

      response = await database.from('notifications').count().eq('student_id', studentId).eq('is_viewed', false);
    }
    else {
      final instructorInfo = await getCurrentInstructorInfo();
      if (instructorInfo == null) {
        throw Exception("instructor record not found");
      }
      final instructorId = instructorInfo['id'];

      response = await database.from('notifications').count().not('instructor_id', 'is', null).eq('instructor_id', instructorId).eq('is_viewed', false);
    }
    Logger().d(response);
    return response ?? 0;
  }

  Future<void> sendReport({required String body, required String header}) async {
    bool isSenderStudent = await isUserStudent();

    if(isSenderStudent){
      final studentInfo = await getCurrentStudentInfo();
      if (studentInfo == null) {
        throw Exception("Student record not found");
      }
      final studentId = studentInfo['id'];

      await database.from('report').insert({
        'student_id' : studentId,
        'is_opened' : false,
        'header' : header,
        'body' : body,
        'status' : 'Sent'
      });
    }

    else {
      final instructorInfo = await getCurrentInstructorInfo();
      if (instructorInfo == null) {
        throw Exception("Student record not found");
      }
      final instructorId = instructorInfo['id'];

      await database.from('report').insert({
        'instructor_id' : instructorId,
        'is_opened' : false,
        'header' : header,
        'body' : body
      });
    }
  }

  Future markNotifsViewed() async {
    bool isStudent = await isUserStudent();
    
    int response;

    if(isStudent) {
      final studentInfo = await getCurrentStudentInfo();
      if (studentInfo == null) {
        throw Exception("Student record not found");
      }
      final studentId = studentInfo['id'];

      response = await database.from('notifications').update({
        'is_viewed' : true
      }).eq('student_id', studentId);
    }
    else {
      final instructorInfo = await getCurrentInstructorInfo();
      if (instructorInfo == null) {
        throw Exception("instructor record not found");
      }
      final instructorId = instructorInfo['id'];

      response = await database.from('notifications').update({
        'is_viewed' : true
      }).eq('instructor_id', instructorId);    
    }
    Logger().d(response);
    return response;
  }
}

