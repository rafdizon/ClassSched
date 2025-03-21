import 'package:class_sched/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientDBManager {
  final logger = Logger();
  final database = Supabase.instance.client;
  final authService = AuthService();
  
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

  Future<List<Map<String, dynamic>>?> getCurrentStudentSched() async {
    final user = database.auth.currentUser;
    if (user == null) return null;

    final response = await database
    .from('student_schedule')
    .select('id, student(id, email, student_no), schedule_time(id, days, start_time, end_time, curriculum(id, year_level, semester_no, subject(id, name, code, units, is_general_subject), course(id, name, major, short_form)), cycle(id, cycle_no, start_date, end_date, semester(id, number, start_date, end_date, academic_year)), instructor(id, first_name, middle_name, last_name, is_full_time, sex, email), section(id, year_level))')
    .eq('student.email', user.email!);

    logger.d(response);
    return response;
  }
}

