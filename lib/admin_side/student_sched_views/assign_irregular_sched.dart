import 'dart:math';

import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/student_accounts_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/select_class_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AssignIrregularSched extends StatefulWidget {
  final Map<String, dynamic> studentMap;
  final List<Map<String, dynamic>> schedule;
  final int semNo;
  const AssignIrregularSched({super.key, required this.schedule, required this.semNo, required this.studentMap});

  @override
  State<AssignIrregularSched> createState() => _AssignIrregularSchedState();
}

class _AssignIrregularSchedState extends State<AssignIrregularSched> {
  late List<Map<String, dynamic>> _schedList;
  List<int> _removedSubjectIds = [];
  bool _isLoading = true;
  final _horizontalScroll = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _schedList = widget.schedule
      .where((sched) =>
          sched['schedule_time']['cycle'] != null &&
          sched['schedule_time']['cycle']['semester'] != null &&
          sched['schedule_time']['cycle']['semester']['number'] == widget.semNo)
      .toList();

    _isLoading = false;
  }

  Future _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });
    for(var sched in _schedList) {
      await AdminDBManager().addIrregSchedule(
        studentId: widget.studentMap['id'], 
        schedTimeId: sched['schedule_time']['id'],
      );
    }

    for(var removed in _removedSubjectIds) {
      await AdminDBManager().deleteScheduleStudent(id: removed);
    }
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) 
      : Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal:70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Edit irregular student schedule',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                TextButton(
                  onPressed: () async {
                    await _saveSchedule();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule successfully edited!'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      )
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentAccountsPage())
                    );
                  },
                  child: Text(
                    'Save Schedule',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              '${widget.studentMap['last_name']}, ${widget.studentMap['first_name']} ${widget.studentMap['middle_name'].toString().isNotEmpty ? widget.studentMap['middle_name'].toString().substring(0,1) : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${widget.studentMap['student_no']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${widget.studentMap['short_form']}-${widget.studentMap['year_level']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Builder(
              builder: (context) {
                final rows = _schedList.map((sched){
                  Logger().i(sched);
                  return DataRow(
                    cells: [
                      DataCell(
                        IconButton(
                          onPressed: (){
                            setState(() {
                              _removedSubjectIds.add(sched['id']);
                              _schedList.remove(sched);
                            });
                          }, 
                          icon: const Icon(Icons.delete, color: Colors.red,)
                        ),
                      ),
                      DataCell(
                        Text(
                          sched['schedule_time']['curriculum']['subject']['code'],
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          sched['schedule_time']['curriculum']['subject']['name'],
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          '${sched['schedule_time']['section']['course']['short_form']}-${sched['schedule_time']['section']['year_level']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          sched['schedule_time']['cycle']['cycle_no'],
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          '${sched['schedule_time']['cycle']['start_date']} to ${sched['schedule_time']['cycle']['end_date']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          '${sched['schedule_time']['start_time']} to ${sched['schedule_time']['end_time']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          sched['schedule_time']['days'].join(', '),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                      DataCell(
                        Text(
                          '${sched['schedule_time']['instructor']['first_name']} ${sched['schedule_time']['instructor']['last_name']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ]
                  );
                }).toList();
        
                return Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  controller: _horizontalScroll,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalScroll,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                        columns: [
                          const DataColumn(
                            label: Text(
                              ''
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Subject Code',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Subject Name',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Section',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Cycle',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Date',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Time',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Days',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Instructor',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ),
                        ], 
                        rows: rows
                      ),
                    ),
                  ),
                );
              }
            ),
            TextButton(
              onPressed: () async {
                final selected = await showDialog(
                  context: context, 
                  builder: (context) => SelectClassDialog(semNo: widget.semNo, currentScheds: _schedList,)
                );
                if(selected != null) {
                  setState(() {
                    Map<String, dynamic> newClass = {
                      "id" : Random().nextInt(20000) + 10000,
                      "schedule_time" : selected,
                      "student_id" : widget.studentMap['id'] 
                    };
                    _schedList.add(newClass);
                  });
                }
              }, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 10,),
                  Text(
                    'ADD A CLASS',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}