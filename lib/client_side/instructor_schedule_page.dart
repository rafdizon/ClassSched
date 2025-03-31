import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:intl/intl.dart';
class InstructorSchedulePage extends StatefulWidget {
  const InstructorSchedulePage({super.key});

  @override
  State<InstructorSchedulePage> createState() => _InstructorSchedulePageState();
}

class _InstructorSchedulePageState extends State<InstructorSchedulePage> {
  String? _selectedSemester;

  String _formatTime(String timeStr) {
    final parsedTime = DateFormat("HH:mm:ss").parse(timeStr);
    return DateFormat("hh:mm a").format(parsedTime);
  }
  String _formatDate(String dateStr) {
    final parsedDate = DateFormat("yyyy-MM-dd").parse(dateStr);
    return DateFormat("MMMM-dd-yyyy").format(parsedDate);
  }
  int _parseTime(String timeStr) {
    try {
      final timeParts = timeStr.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }
  Set<int> _getConflictIds(List<Map<String, dynamic>> subjects) {
    final conflictIds = <int>{};

    for (int i = 0; i < subjects.length; i++) {
      final schedA = subjects[i]['schedule_time'];
      final cycleIdA = schedA['cycle']['id'];
      final daysA = schedA['days'] as List<dynamic>;
      final startA = _parseTime(schedA['start_time']);
      final endA = _parseTime(schedA['end_time']);

      for (int j = i + 1; j < subjects.length; j++) {
        final schedB = subjects[j]['schedule_time'];
        final cycleIdB = schedB['cycle']['id'];
        if (cycleIdA != cycleIdB) continue;

        final daysB = schedB['days'] as List<dynamic>;
        bool dayConflict = daysA.any((day) => daysB.contains(day));
        if (!dayConflict) continue;

        final startB = _parseTime(schedB['start_time']);
        final endB = _parseTime(schedB['end_time']);

        bool timeOverlap = startA < endB && startB < endA;
        if (timeOverlap) {
          conflictIds.add(schedA['id'] as int);
          conflictIds.add(schedB['id'] as int);
        }
      }
    }
    return conflictIds;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClientDBManager().getCurrentInstructorSched(), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        }
        else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final scheds = snapshot.data as List<Map<String, dynamic>>;
        if(scheds.isEmpty) {
          return Center(child: Text('No schedules yet...', style: Theme.of(context).textTheme.bodyMedium,),);
        }
        final semesterSet = scheds.map((sched) {
          return sched['schedule_time']['cycle']['semester']['number'].toString();
        }).toSet();

        final semesters = semesterSet.toList()..sort();

        if (_selectedSemester == null && semesters.isNotEmpty) {
          _selectedSemester = semesters.first;
        }

        final filteredScheds = scheds.where((sched) {
          return sched['schedule_time']['cycle']['semester']['number'].toString() == _selectedSemester;
        }).toList();

        final conflictIds = _getConflictIds(filteredScheds);

        final schedRows = filteredScheds.map((sched) {
          final schedTimeId = sched['schedule_time']['id'] as int;
          final rowColor = conflictIds.contains(schedTimeId) ? Colors.red[200] : Colors.transparent;
          return DataRow(
            color: WidgetStatePropertyAll(rowColor),
            cells: [
              DataCell(
                Text(
                  sched['schedule_time']['section'] != null ? '${sched['schedule_time']['section']['course']['short_form']}-${sched['schedule_time']['section']['year_level']}' : ' ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  sched['schedule_time']['curriculum']['subject']['code'],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  sched['schedule_time']['curriculum']['subject']['name'],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  sched['schedule_time']['curriculum']['subject']['units'].toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  sched['schedule_time']['cycle']['cycle_no'].toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  '${_formatDate(sched['schedule_time']['cycle']['start_date'])} to ${_formatDate(sched['schedule_time']['cycle']['end_date'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  sched['schedule_time']['days'].join(','),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  '${_formatTime(sched['schedule_time']['start_time'])} to ${_formatTime(sched['schedule_time']['end_time'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]
          );
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedSemester,
                items: semesters.map((semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text('Semester $semester'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSemester = newValue;
                  });
                },
              ),
            ),
            Text(
              'Note: Notify admin immediately in case of schedule conflicts by sending a report.', 
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                    columns: [
                      DataColumn(
                        label: Text('Course', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Code', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Subject', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Units', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Cycle', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Date', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Days', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                      DataColumn(
                        label: Text('Time', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                    ], 
                    rows: schedRows
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
