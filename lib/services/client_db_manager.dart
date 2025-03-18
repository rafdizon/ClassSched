import 'package:class_sched/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientDBManager {
  final database = Supabase.instance.client;
  final authService = AuthService();

  Future<Map<String, dynamic>?> getCurrentStudentInfo() async {
    final user = database.auth.currentUser;
    if (user == null) return null; // No logged-in user

    final response = await database
        .from('student')
        .select()
        .eq('email', user.email!) // Fetch student info using logged-in email
        .maybeSingle(); // Avoid errors if no match

    return response;
  }
}