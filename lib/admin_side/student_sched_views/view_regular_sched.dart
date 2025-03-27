import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class ViewRegularSched extends StatefulWidget {
  final int studentId;
  const ViewRegularSched({super.key, required this.studentId});

  @override
  State<ViewRegularSched> createState() => _ViewRegularSchedState();
}

class _ViewRegularSchedState extends State<ViewRegularSched> {
  String? _selectedSemester;

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: FutureBuilder(
          future: AdminDBManager().getSchedulesForStudent(studentId: widget.studentId), 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
        
            final scheds = snapshot.data as List<Map<String, dynamic>>;
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
        
            final schedRows = filteredScheds.map((sched) {
              return DataRow(
                cells: [
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
                      '${sched['schedule_time']['instructor']['first_name']} ${sched['schedule_time']['instructor']['middle_name']}${sched['schedule_time']['instructor']['middle_name'].toString().isEmpty ? '' : ' '}${sched['schedule_time']['instructor']['last_name']}',
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
                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                        columns: [
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
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}