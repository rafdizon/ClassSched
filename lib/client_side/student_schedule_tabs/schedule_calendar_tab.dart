import 'package:class_sched/services/client_db_manager.dart';
import 'package:class_sched/services/notifications_student_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:class_sched/services/notification_utils.dart';
import 'package:intl/intl.dart';
class ScheduleCalendarTab extends StatefulWidget {
  const ScheduleCalendarTab({super.key});

  @override
  State<ScheduleCalendarTab> createState() => _ScheduleCalendarTabState();
}

class _ScheduleCalendarTabState extends State<ScheduleCalendarTab> {
  final clientDBManager = ClientDBManager();
  List<Appointment> appointments = [];

  final CalendarController _dateController = CalendarController();
  DateTime _selectedDate = DateTime.now();

  Future<void> fetchAppointments() async {
    final response = await clientDBManager.getCurrentStudentSched();
    List data;
    if (response != null && response.any((map) => map['student'] == null)){
      data = [];
    }
    else {
      data = response as List<Map<String, dynamic>>;
    }
    List<Appointment> loadedAppointments = [];

    Map<int, Map<String, dynamic>> appointmentScheduleTime = {};
    for (var i = 0; i < data.length; i++) {
      final scheduleTime = data[i]['schedule_time'];
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
        subject: '${scheduleTime['curriculum']['subject']['code'].toString()}: ${scheduleTime['curriculum']['subject']['name'].toString()}',
        recurrenceRule: recurrenceRule,
        color: Theme.of(context).colorScheme.secondary,
        notes: scheduleTime['id'].toString()
      );
      loadedAppointments.add(appointment);

      appointmentScheduleTime[i] = {
        'cycle_start': cycleStartDate,
        'cycle_end': cycleEndDate,
      };
    }

    setState(() {
      appointments = loadedAppointments;
    });
    for (var i = 0; i < appointments.length; i++) {
      final cycleDates = appointmentScheduleTime[i]!;
      final cycleStart = cycleDates['cycle_start'] as DateTime;
      final cycleEnd = cycleDates['cycle_end'] as DateTime;

      final occurrences = computeAllOccurrences(appointments[i], cycleStart, cycleEnd);

      for (var j = 0; j < occurrences.length; j++) {
        final occurrenceAppointment = cloneAppointmentWithNewStartTime(appointments[i], occurrences[j]);
        final notificationId = i * 100 + j; 
        NotificationsStudentService().scheduleNotif(appointment: occurrenceAppointment, id: notificationId);
      }
    }
  }

  String _formatTime(String timeStr) {
    final parsedTime = DateFormat("HH:mm:ss").parse(timeStr);
    return DateFormat("hh:mm a").format(parsedTime);
  }
  String _formatDate(String dateStr) {
    final parsedDate = DateFormat("yyyy-MM-dd").parse(dateStr);
    return DateFormat("MMMM-dd-yyyy").format(parsedDate);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAppointments();
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reloadPage,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SfCalendar(
              headerStyle: CalendarHeaderStyle(
                backgroundColor: Theme.of(context).colorScheme.secondary
              ),
              view: CalendarView.month,
              dataSource: MeetingDataSource(appointments),
              
              onSelectionChanged: (details) {
                setState(() {
                  Logger().d(details.date.toString());
                  _selectedDate = details.date!;
                  _dateController.selectedDate = _selectedDate;
                  _dateController.displayDate = _selectedDate;
                });
              },
            ),
            SfCalendar(
              view: CalendarView.day,
              initialDisplayDate: _selectedDate,
              controller: _dateController,
              dataSource: MeetingDataSource(appointments),
              headerHeight: 0,
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  final Appointment appointment = details.appointments!.first;
      
                  showDialog(
                    context: context, 
                    builder: (context) => Dialog (
                      child: FutureBuilder(
                        future: clientDBManager.getScheduleTime(id: int.parse(appointment.notes!)), 
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(),);
                          }
                          else if (snapshot.hasError) {
                            return Center(child: Text(snapshot.error.toString()),);
                          }
                          final sched = snapshot.data as Map<String,dynamic>;
      
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Subject Details', style: Theme.of(context).textTheme.bodyMedium,),
                                Divider(color: Theme.of(context).colorScheme.primary,),
                                Table(
                                  columnWidths: const {
                                    0 : FractionColumnWidth(0.35),
                                    1 : FractionColumnWidth(0.65)
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Text('Subject: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text(sched['curriculum']['subject']['name'], style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        Text('Units: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text(sched['curriculum']['subject']['units'].toString(), style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        Text('Instructor: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text('${sched['instructor']['first_name']} ${sched['instructor']['last_name']}', style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20,),
                                Text('Schedule Details', style: Theme.of(context).textTheme.bodyMedium,),
                                Divider(color: Theme.of(context).colorScheme.primary,),
                                Table(
                                  columnWidths: const {
                                    0 : FractionColumnWidth(0.35),
                                    1 : FractionColumnWidth(0.65)
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Text('Cycle: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text(sched['cycle']['cycle_no'].toString(), style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        Text('Date: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text('${_formatDate(sched['cycle']['start_date'])} to ${_formatDate(sched['cycle']['end_date'])}', style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        Text('Days: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text(sched['days'].join(', '), style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        Text('Start Time: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text(_formatTime(sched['start_time'].toString()), style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        Text('End Time: ', style: Theme.of(context).textTheme.bodySmall,),
                                        Text(_formatTime(sched['end_time'].toString()), style: Theme.of(context).textTheme.bodySmall,),
                                      ]
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    )
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _reloadPage() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {});
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
