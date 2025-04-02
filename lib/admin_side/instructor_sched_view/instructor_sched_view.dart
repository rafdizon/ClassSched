import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class InstructorSchedView extends StatefulWidget {
  final instructorId;
  const InstructorSchedView({super.key, required this.instructorId});

  @override
  State<InstructorSchedView> createState() => _InstructorSchedViewState();
}

class _InstructorSchedViewState extends State<InstructorSchedView> {
  String? _selectedSem;

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: FutureBuilder(
        future: AdminDBManager().getInstructorSched(instructorId: widget.instructorId), 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else if(snapshot.data == null || !snapshot.hasData) {
            return const Center(child: Text('Failed to load data, check internet connection'));
          }
          final scheds = snapshot.data as List<Map<String, dynamic>>;
          final semesterSet = scheds.map((sched) {
            return sched['schedule_time']['cycle']['semester']['number'].toString();
          }).toSet();

          final semesters = semesterSet.toList()..sort();

          if (_selectedSem == null && semesters.isNotEmpty) {
            _selectedSem = semesters.first;
          }
          final filteredScheds = scheds.where((sched) {
            return sched['schedule_time']['cycle']['semester']['number'].toString() == _selectedSem;
          }).toList();

          final schedRows = filteredScheds.map((sched) {
            return DataRow(
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
                    '${sched['schedule_time']['cycle']['start_date']} to ${sched['schedule_time']['cycle']['end_date']}',
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
                    '${sched['schedule_time']['start_time']} to ${sched['schedule_time']['end_time']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DataCell(
                  Text(
                    '${sched['instructor']['first_name']} ${sched['instructor']['middle_name']}${sched['instructor']['middle_name'].toString().isEmpty ? '' : ' '}${sched['instructor']['last_name']}',
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
                  value: _selectedSem,
                  items: semesters.map((semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text('Semester $semester'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSem = newValue;
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
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
                      DataColumn(
                        label: Text('Instructor', style: Theme.of(context).textTheme.bodySmall,)
                      ),
                    ], 
                    rows: schedRows
                  ),
                ),
              ),
            ],
          );
        }
      )
    );
  }
}