import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class StudentSchedulePage extends StatefulWidget {
  const StudentSchedulePage({super.key});

  @override
  State<StudentSchedulePage> createState() => _StudentSchedulePageState();
}

class _StudentSchedulePageState extends State<StudentSchedulePage> {
  final clientDBManager = ClientDBManager();
  List<Appointment> appointments = [];

  String convertDayToRRule(String day) {
    switch (day) {
      case 'M': return 'MO';
      case 'T': return 'TU';
      case 'W': return 'WE';
      case 'Th': return 'TH';
      case 'F': return 'FR';
      case 'Sa': return 'SA';
      case 'Su': return 'SU';
      default: return '';
    }
  }

  Future<void> fetchAppointments() async {
    final response = await clientDBManager.getCurrentStudentSched();

    final data = response as List<Map<String, dynamic>>;
    List<Appointment> loadedAppointments = [];

    for (var item in data) {
      final scheduleTime = item['schedule_time'];
      final cycleStartDate = DateTime.parse(scheduleTime['cycle']['start_date']);
      final startTime = DateTime.parse("${cycleStartDate.toIso8601String().split('T')[0]} ${scheduleTime['start_time']}");
      final endTime = DateTime.parse("${cycleStartDate.toIso8601String().split('T')[0]} ${scheduleTime['end_time']}");
      final cycleEndDate = DateTime.parse(scheduleTime['cycle']['end_date']);

      final formattedEndDate = DateTime(cycleEndDate.year, cycleEndDate.month, cycleEndDate.day, 23, 59, 59)
        .toUtc()
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .split('.')[0] + 'Z';

      List<dynamic> daysList = scheduleTime['days'];
      final rruleDays =
          daysList.map((day) => convertDayToRRule(day as String)).join(',');
      
      final recurrenceRule = 'FREQ=WEEKLY;BYDAY=$rruleDays;UNTIL=$formattedEndDate';
      final appointment = Appointment(
        startTime: startTime,
        endTime: endTime,
        subject: scheduleTime['curriculum']['subject']['code'].toString(),
        recurrenceRule: recurrenceRule
      );
      loadedAppointments.add(appointment);
    }

    setState(() {
      appointments = loadedAppointments;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAppointments();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfCalendar(
          view: CalendarView.month,
          dataSource: MeetingDataSource(appointments),
        )
      ],
    );
  }
}
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}