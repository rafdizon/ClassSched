import 'package:class_sched/admin_side/dashboard_page.dart';
import 'package:class_sched/log_in_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        //final session = snapshot.hasData ? snapshot.data!.session : null;

        if(session != null) {
          return DashboardPage();
        }
        else {
          return LogInPage();
        }
      }
    );
  }
}