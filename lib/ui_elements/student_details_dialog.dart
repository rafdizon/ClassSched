import 'package:class_sched/admin_side/student_sched_views/edit_irregular_sched.dart';
import 'package:class_sched/admin_side/student_sched_views/view_regular_sched.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';


class StudentDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> studentMap;
  const StudentDetailsDialog({super.key, required this.studentMap});

  @override
  State<StudentDetailsDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends State<StudentDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.person, 
                    color: Theme.of(context).colorScheme.secondary,
                    size: 200,
                  ),
                  Table(
                    columnWidths: const {
                      0 : FractionColumnWidth(0.3),
                      1 : FractionColumnWidth(0.7)
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'Name: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.studentMap['last_name']}, ${widget.studentMap['first_name']} ${widget.studentMap['middle_name'].toString().isNotEmpty ? widget.studentMap['middle_name'].toString().substring(0,1) : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Student no.: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.studentMap['student_no']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Email: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.studentMap['email'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 20,),
                          SizedBox(height: 20,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Course: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.studentMap['course']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Major: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.studentMap['major']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Year: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.studentMap['year_level']}${widget.studentMap['year_level'] == 1 ? 'st' 
                            : widget.studentMap['year_level'] == 2 ? 'nd'
                            : widget.studentMap['year_level'] == 3 ? 'rd'
                            : 'th'} year',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 20,),
                          SizedBox(height: 20,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Status: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.studentMap['is_regular'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Sex: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.studentMap['sex'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                    ],
                  ),
                ],
              ),
              FutureBuilder(
                future: widget.studentMap['is_regular'] == 'Regular' ? AdminDBManager().getSchedulesForStudent(studentId: widget.studentMap['id']) 
                  : AdminDBManager().getSchedulesForIrregStudent(studentId: widget.studentMap['id']) , 
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LinearProgressIndicator(),);
                  }
                  else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  final scheduleData = snapshot.data as List<Map<String, dynamic>>;

                  if(widget.studentMap['is_regular'] == 'Regular') {
                    return TextButton(
                      onPressed: (){
                        scheduleData.isNotEmpty ? Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ViewRegularSched(studentId: widget.studentMap['id'],))
                        ) : showDialog(
                            context: context, 
                            builder: (context) => AlertDialog(
                              title: Text('Schedule', style: Theme.of(context).textTheme.bodyMedium,),
                              content: Text('No schedule yet for their section, create one in Schedule Manager', style: Theme.of(context).textTheme.bodySmall,),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }, 
                                  child: Text('OK')
                                )
                              ],
                            )
                          );
                      }, 
                      child: Text(
                        'View Schedule',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    );
                  }
                  else {
                    return TextButton(
                      onPressed: () async {
                        if (scheduleData.isNotEmpty) {
                          final groupedBySem = groupBy(
                              scheduleData,
                              (map) => map["schedule_time"]["cycle"]["semester"]["number"]
                          );
                          
                          final semesterButtons = groupedBySem.keys.map((semester) {
                            return TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(semester); 
                              },
                              child: Text("Semester $semester"),
                            );
                          }).toList();
                          
                          final selectedSem = await showDialog<int>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Choose a semester:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              actions: semesterButtons,
                            ),
                          );
                          
                          if (selectedSem != null) {
                            Logger().d(selectedSem);
                            Logger().d(scheduleData);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditIrregularSched(
                                  studentId: widget.studentMap['id'],
                                  schedule: scheduleData,
                                  semNo: selectedSem, 
                                ),
                              ),
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Schedule',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              content: Text(
                                'No schedule yet for their section, create one in Schedule Manager',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Edit Schedule',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    );

                  }
                  
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}