import 'package:class_sched/services/settings_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:class_sched/services/notification_utils.dart';
import 'package:class_sched/services/client_db_manager.dart';
import 'package:intl/intl.dart';

class NotificationsStudentService {

  static final NotificationsStudentService _instance =
      NotificationsStudentService._internal();

  factory NotificationsStudentService() => _instance;

  NotificationsStudentService._internal();

  final FlutterLocalNotificationsPlugin notifPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInit = false;

  bool get isInit => _isInit;

  Future<void> initNotif() async {
    if (_isInit) return;

    
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: initSettingsAndroid);

    await notifPlugin.initialize(initSettings);
    _isInit = true;
  }

  NotificationDetails notifDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'sched_notification_channel',
        'Schedule Notifications',
        channelDescription: 'Schedule Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  String formatTime(String rawDate) {
  final parsed = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(rawDate);
  return DateFormat("hh:mm a").format(parsed);
}

  Future<void> showNotif({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notifPlugin.show(
      id,
      title,
      body,
      notifDetails(),
    );
  }
  

  Future<void> scheduleNotif({
    int id = 1,
    required Appointment appointment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> buffers = [0, 5, 15, 30, 60];
    int bufferIndex = prefs.getInt('bufferIndex') ?? 0;
    int bufferTime = buffers[bufferIndex];

    DateTime notificationTime = appointment.startTime.subtract(Duration(minutes: bufferTime));
    if (appointment.startTime.isBefore(DateTime.now())) return;
    if (!SettingsUtil.isNotifOn) return;
    await notifPlugin.zonedSchedule(
      id,
      appointment.subject,
      'Your class starts at ${formatTime(appointment.startTime.toString())}',
      tz.TZDateTime.from(notificationTime, tz.local),
      notifDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    Logger().i('Scheduling notification for ${appointment.subject} at ${appointment.startTime}');
  }

  Future<void> rescheduleAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    bool isNotifOn = prefs.getBool('isNotifOn') ?? true;
    if (!isNotifOn) return;

    final response = await ClientDBManager().getCurrentStudentSched();
    final data = response as List<Map<String, dynamic>>;
    List<Appointment> loadedAppointments = [];
    Map<int, Map<String, dynamic>> appointmentScheduleTime = {};

    for (var i = 0; i < data.length; i++) {
      final scheduleTime = data[i]['schedule_time'];
      final cycleStartDate = DateTime.parse(scheduleTime['cycle']['start_date']);
      final startTime = DateTime.parse(
          "${cycleStartDate.toIso8601String().split('T')[0]} ${scheduleTime['start_time']}");
      final endTime = DateTime.parse(
          "${cycleStartDate.toIso8601String().split('T')[0]} ${scheduleTime['end_time']}");
      final cycleEndDate = DateTime.parse(scheduleTime['cycle']['end_date']);

      final formattedEndDate = DateTime(cycleEndDate.year, cycleEndDate.month, cycleEndDate.day, 23, 59, 59)
          .toUtc()
          .toIso8601String()
          .replaceAll('-', '')
          .replaceAll(':', '')
          .split('.')[0] + 'Z';

      List<dynamic> daysList = scheduleTime['days'];
      final rruleDays = daysList.map((day) => convertDayToRRule(day as String)).join(',');
      final recurrenceRule = 'FREQ=WEEKLY;BYDAY=$rruleDays;UNTIL=$formattedEndDate';

      final appointment = Appointment(
        startTime: startTime,
        endTime: endTime,
        subject:
            '${scheduleTime['curriculum']['subject']['code']}: ${scheduleTime['curriculum']['subject']['name']}',
        recurrenceRule: recurrenceRule,
        color: const Color.fromARGB(255, 224, 178, 36),
        notes: scheduleTime['id'].toString(),
      );
      loadedAppointments.add(appointment);

      appointmentScheduleTime[i] = {
        'cycle_start': cycleStartDate,
        'cycle_end': cycleEndDate,
      };
    }

    for (var i = 0; i < loadedAppointments.length; i++) {
      final cycleDates = appointmentScheduleTime[i]!;
      final cycleStart = cycleDates['cycle_start'] as DateTime;
      final cycleEnd = cycleDates['cycle_end'] as DateTime;
      final occurrences = computeAllOccurrences(loadedAppointments[i], cycleStart, cycleEnd);
      for (var j = 0; j < occurrences.length; j++) {
        final occurrenceAppointment =
            cloneAppointmentWithNewStartTime(loadedAppointments[i], occurrences[j]);
        final notificationId = i * 100 + j;
        await scheduleNotif(appointment: occurrenceAppointment, id: notificationId);
      }
    }
  }
}
