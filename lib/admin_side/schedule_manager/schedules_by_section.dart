import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

final logger = Logger();
class SchedulesBySection extends StatefulWidget {
  final Map<String, dynamic> section;
  const SchedulesBySection({super.key, required this.section});

  @override
  State<SchedulesBySection> createState() => _SchedulesBySectionState();
}

class _SchedulesBySectionState extends State<SchedulesBySection> {
  final adminDBManager = AdminDBManager();
  var _selectedCycle = {};
  var _selectedInstructor = {};
  
  Map<int, TextEditingController> _startTimeController = {};
  Map<int, TextEditingController> _endTimeController = {};

  var _selectedDays = [];

  final _daysList = [Text("M"), Text("T"), Text("W"), Text("Th"), Text("F"), Text("Sa")];
  //final _daysSelection = [false, false, false, false, false, false];
  Map<int, List<bool>> _daysSelection = {};

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _startTimeController.values.forEach((controller) => controller.dispose());
    _endTimeController.values.forEach((controller) => controller.dispose());
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: adminDBManager.getCurriculum(
        courseId: widget.section['course_id'] as int, 
        yearLevel: widget.section['year_level'] as int
      ), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        final curriculumList = snapshot.data as List<Map<String, dynamic>>;
        final curriculumBySem = groupBy(curriculumList, (s) => s['semester_no']);
        
        return ListView.builder(
          itemCount: curriculumBySem.keys.length,
          itemBuilder: (context, index) {
            final semKey = curriculumBySem.keys.elementAt(index);
            final subjects = curriculumBySem[semKey];
            
            final rows = subjects!.map((subj) {
              logger.d(subj['id']);
              _daysSelection.putIfAbsent(subj['id'], () => List.filled(6, false));
              return SizedBox(
                height: 100,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0 : FractionColumnWidth(0.08),
                        1 : FractionColumnWidth(0.22),
                        2 : FractionColumnWidth(0.08),
                        3 : FractionColumnWidth(0.19),
                        4 : FractionColumnWidth(0.1333),
                        5 : FractionColumnWidth(0.1333),
                        6 : FractionColumnWidth(0.1633),
                      },
                      children: [
                        TableRow(
                          children: [
                            Text(subj['subject']['code'], style: Theme.of(context).textTheme.bodySmall,),
                            Text(subj['subject']['name'], style: Theme.of(context).textTheme.bodySmall,),
                            FutureBuilder(
                              future: adminDBManager.getCycles(), 
                              builder: (context, snapshot) {
                                if(snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(),);
                                }
                                else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }

                                final cyclesList = snapshot.data as List<Map<String, dynamic>>;
                                final cyclesBySem = groupBy(cyclesList, (cycle) => cycle['semester']['number']);
                                final cyclesForSem = cyclesBySem[semKey] ?? [];
                                final cyclesDropdown = cyclesForSem.map((cycle) {
                                  return DropdownMenuItem(
                                    value: cycle['id'],
                                    child: Text(
                                      cycle['cycle_no'],
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  );
                                }).toList();

                                return SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: ButtonTheme(
                                    minWidth: 30,
                                    alignedDropdown: true,
                                    child: DropdownButton(
                                      hint: const Text('Cycle'),
                                      value: _selectedCycle[subj['id']],
                                      items: cyclesDropdown,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedCycle[subj['id']] = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                            ),
                            Center(
                              child: ToggleButtons(
                                isSelected: _daysSelection[subj['id']]!,
                                onPressed: (index) {
                                  setState(() {
                                    _daysSelection[subj['id']]![index] = !_daysSelection[subj['id']]![index];
                                  });
                                },
                                textStyle: Theme.of(context).textTheme.bodySmall,
                                constraints: const BoxConstraints(minWidth: 30, maxWidth: 100),
                                selectedColor: Theme.of(context).colorScheme.primary,
                                hoverColor: Theme.of(context).colorScheme.secondary.withAlpha(150),
                                fillColor: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                                children: _daysList,
                                
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: _startTimeController.putIfAbsent(subj['id'], () => TextEditingController()),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Start Time",
                                    labelStyle: Theme.of(context).textTheme.bodySmall,
                                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  onTap: () async {
                                    _selectStartTime(refId:  subj['id']);
                                  },
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: _endTimeController.putIfAbsent(subj['id'], () => TextEditingController()),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "End Time",
                                    labelStyle: Theme.of(context).textTheme.bodySmall,
                                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary,),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  onTap: () async {
                                    _selectEndTime(refId:  subj['id']);
                                  },
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: adminDBManager.getinstructors(), 
                              builder: (context, snapshot) {
                                if(snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(),);
                                }
                                else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }

                                final instructorsList = snapshot.data as List<Map<String, dynamic>>;
                                final instructorsDropdown = instructorsList.map((inst) {
                                  return DropdownMenuItem(
                                    value: inst['id'],
                                    child: Text(
                                      '${inst['first_name']} ${inst['last_name']}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    )
                                  );
                                }).toList();
                                return SizedBox(
                                  child: DropdownButton(
                                    hint: const Text('Instructor'),
                                    items: instructorsDropdown, 
                                    value: _selectedInstructor[subj['id']],
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedInstructor[subj['id']] = newValue;
                                      });
                                    }
                                  ),
                                );
                              }
                            ),
                          ]
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Semester $semKey"),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: rows.length * 100),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rows.length, 
                      itemBuilder: (context, index) => rows[index]
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
  Future _selectStartTime({required int refId}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context, 
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), 
          child: child!,
        );
      }
    );
    if (pickedTime != null) {
      setState(() {
        _startTimeController[refId]?.text = '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }
  Future _selectEndTime({required int refId}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context, 
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), 
          child: child!,
        );
      }
    );
    if (pickedTime != null) {
      setState(() {
        _endTimeController[refId]?.text = '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }
}