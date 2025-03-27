import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password
    );
  }

  Future<AuthResponse> signUpWithEmailAndPassword(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password
    );
  }

  Future<void> resetPassword(String email) async {
    return await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  

  // Future<void> completePasswordReset(String token, String newPassword) async {
  //   final url = '$URL/auth/v1/recover';
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'apikey': ANON_KEY,
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({'password': newPassword}),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to reset password: ${response.body}');
  //   }
  // }
}