import 'package:class_sched/auth_gate.dart';
import 'package:class_sched/services/notifications_student_service.dart';
import 'package:class_sched/services/settings_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:window_manager/window_manager.dart';

late String ANON_KEY;
late String URL;
late String ADMIN_EMAIL;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  ANON_KEY = dotenv.env['ANON_KEY']!;
  URL = dotenv.env['URL']!;
  ADMIN_EMAIL = dotenv.env['ADMIN_EMAIL']!;
  await Supabase.initialize(
    anonKey: ANON_KEY,
    url: URL,
  );
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  Logger().d(timeZoneName);
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  if(!Platform.isWindows) {
    await SettingsUtil.loadSettings();
    await NotificationsStudentService().initNotif();
  }
  else if (Platform.isWindows){
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(1000, 600));
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassSched',
      restorationScopeId: 'class-sched',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 117, 74),
          primary: const Color.fromARGB(255, 17, 117, 74),
          secondary: const Color.fromARGB(255, 224, 178, 36),
          tertiary: const Color.fromARGB(255, 236, 236, 236)
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold
          ),
          displayMedium: TextStyle(
            fontSize: 40,
          ),
          titleLarge: TextStyle(
            fontSize: 32
          ),
          bodyLarge: TextStyle(
            fontSize: 26
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
          ),
          bodySmall: TextStyle(
            fontSize: 14
          ),
          labelSmall: TextStyle(
            fontSize: 10,
          ),
          displaySmall: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold
          )
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.black26,
            fontSize: 14
          ),
          
        ),
        useMaterial3: true,
      ),
      home: const AuthGate()
    );
  }
}
