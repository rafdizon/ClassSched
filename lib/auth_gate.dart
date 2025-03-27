import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/dashboard_page.dart';
import 'package:class_sched/client_side/default_layout.dart';
import 'package:class_sched/client_side/student_profile_page.dart';
import 'package:class_sched/log_in_page.dart';
import 'package:class_sched/main.dart';
import 'package:class_sched/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final session = Supabase.instance.client.auth.currentSession;

        if(session != null) {
          final userEmail = session.user.email;

          if(userEmail == ADMIN_EMAIL) {
            if (!Platform.isWindows) {
              return const Scaffold(
                body: Center(
                  child: Text("Admin access is only allowed on Windows."),
                ),
              );
            }
            return const BaseLayout(body: DashboardPage(),);
          }
          else {
            if(Platform.isWindows){
              Future.microtask(() => AuthService().signOut());
              return const Center(child: CircularProgressIndicator(color: Colors.red,),);
            }
            return const DefaultLayout();
          }
        }
        else {
          return const LogInPage();
        }
      }
    );
  }
}