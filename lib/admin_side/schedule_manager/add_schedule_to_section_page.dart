import 'package:class_sched/admin_side/schedule_manager/schedules_by_course_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_subject_to_sched_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ScheduleEntry {
  dynamic selectedCycle;
  dynamic selectedInstructor;
  TextEditingController startTimeController;
  TextEditingController endTimeController;
  List<bool> daysSelection;

  ScheduleEntry({
  this.selectedCycle,
  this.selectedInstructor,
  TextEditingController? startTimeController,
  TextEditingController? endTimeController,
  List<bool>? daysSelection,
  })  : startTimeController = startTimeController ?? TextEditingController(),
      endTimeController = endTimeController ?? TextEditingController(),
      daysSelection = daysSelection ?? List.filled(6, false);
}

class AddScheduleToSection extends StatefulWidget {
  final Map<String, dynamic> section;
  const AddScheduleToSection({super.key, required this.section});

  @override
  State<AddScheduleToSection> createState() => _AddScheduleToSectionState();
}

class _AddScheduleToSectionState extends State<AddScheduleToSection> {
  final adminDBManager = AdminDBManager();
  Map<int, ScheduleEntry>  _scheduleEntries = {};
  List<int> _removedSubjectIds = [];

  final _daysList = [Text("M"), Text("T"), Text("W"), Text("Th"), Text("F"), Text("Sa")];
  
  late Future<dynamic> _curriculumFuture;
  late Future<dynamic> _cyclesFuture;
  late Future<dynamic> _instructorsFuture;

  List<Map<String, dynamic>> _curriculumList = [];
  bool _isLoading = true;

  int _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return 0;
      final timePart = parts[0]; // e.g., "8:00"
      final period = parts[1]; // "AM" or "PM"
      final timeParts = timePart.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  bool _hasConflict(int subjectId, List<Map<String, dynamic>> visibleSubjects) {
    final currentEntry = _scheduleEntries[subjectId];
    if (currentEntry == null ||
        currentEntry.startTimeController.text.isEmpty ||
        currentEntry.endTimeController.text.isEmpty ||
        currentEntry.selectedCycle == null) {
      return false;
    }
    int currentStart = _parseTime(currentEntry.startTimeController.text);
    int currentEnd = _parseTime(currentEntry.endTimeController.text);

    for (var subj in visibleSubjects) {
      if (subj['id'] == subjectId) continue;
      final otherEntry = _scheduleEntries[subj['id']];
      if (otherEntry == null ||
          otherEntry.startTimeController.text.isEmpty ||
          otherEntry.endTimeController.text.isEmpty ||
          otherEntry.selectedCycle == null) {
        continue;
      }
      if (currentEntry.selectedCycle == otherEntry.selectedCycle) {
        if (_daysOverlap(currentEntry.daysSelection, otherEntry.daysSelection)) {
          int otherStart = _parseTime(otherEntry.startTimeController.text);
          int otherEnd = _parseTime(otherEntry.endTimeController.text);

          if (currentStart < otherEnd && otherStart < currentEnd) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _daysOverlap(List<bool> daysA, List<bool> daysB) {
    for (int i = 0; i < daysA.length; i++) {
      if (daysA[i] && daysB[i]) return true;
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    adminDBManager.getCurriculum(
      courseId: widget.section['course']['id'] as int, 
      yearLevel: widget.section['year_level'] as int,
    ).then((data) {
      setState(() {
        _curriculumList = data;
        _isLoading = false;
      });
    });
    _cyclesFuture = adminDBManager.getCycles();
    _instructorsFuture = adminDBManager.getinstructors();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _scheduleEntries.values.forEach((entry) {
      entry.startTimeController.dispose();
      entry.endTimeController.dispose();
    });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final curriculumBySem = groupBy(_curriculumList, (s) => s['semester_no']);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.section['course']['short_form']}-${widget.section['year_level']} Schedule',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextButton(
                onPressed: _saveSchedules, 
                child: Text(
                  'Save Schedule', 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: curriculumBySem.keys.length,
              itemBuilder: (context, index) {
                final semKey = curriculumBySem.keys.elementAt(index);
                final subjects = curriculumBySem[semKey];
                
                final visibleSubjects = subjects!.where((subj) => !_removedSubjectIds.contains(subj['id'])).toList();
                final rows = visibleSubjects.map((subj) {
                  final scheduleEntry = _scheduleEntries.putIfAbsent(subj['id'], () => ScheduleEntry());
                  bool hasConflict = _hasConflict(subj['id'], visibleSubjects);
                  return SizedBox(
                    height: 100,
                    child: Card(
                      color: hasConflict ? Colors.red[200] : null,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Table(
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0 : FractionColumnWidth(0.05),
                            1 : FractionColumnWidth(0.08),
                            2 : FractionColumnWidth(0.20),
                            3 : FractionColumnWidth(0.08),
                            4 : FractionColumnWidth(0.19),
                            5 : FractionColumnWidth(0.1333),
                            6 : FractionColumnWidth(0.1333),
                            7 : FractionColumnWidth(0.1333),
                          },
                          children: [
                            TableRow(
                              children: [
                                Center(
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context, 
                                        builder: (context) => AlertDialog(
                                          title: Text('Remove ${subj['subject']['name']}?'),
                                          content: const Text('This cannot be reversed'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context), 
                                              child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _removedSubjectIds.add(subj['id']);
                                                  _scheduleEntries.remove(subj['id']);
                                                });
                                                Navigator.pop(context);
                                              }, 
                                              child: Text('Delete', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),),
                                            ),
                                          ],
                                        )
                                      );
                                      
                                    }, 
                                    icon: const Icon(Icons.delete, color: Colors.red,)
                                  ),
                                ),
                                Text(subj['subject']['code'], style: Theme.of(context).textTheme.bodySmall,),
                                Text(subj['subject']['name'], style: Theme.of(context).textTheme.bodySmall,),
                                FutureBuilder(
                                  future: _cyclesFuture, 
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
                                          value: scheduleEntry.selectedCycle,
                                          items: cyclesDropdown,
                                          onChanged: (newValue) {
                                            setState(() {
                                              scheduleEntry.selectedCycle = newValue;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                ),
                                Center(
                                  child: ToggleButtons(
                                    isSelected: scheduleEntry.daysSelection,
                                    onPressed: (index) {
                                      setState(() {
                                        scheduleEntry.daysSelection[index] = !scheduleEntry.daysSelection[index];
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
                                      controller: scheduleEntry.startTimeController,
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
                                      controller: scheduleEntry.endTimeController,
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
                                  future: _instructorsFuture, 
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
                                        value: scheduleEntry.selectedInstructor,
                                        onChanged: (newValue) {
                                          setState(() {
                                            scheduleEntry.selectedInstructor = newValue;
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
        
                return Column(
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
                    TextButton(
                      onPressed: () async {
                        final selectedSubject = await showDialog(
                          context: context, 
                          builder: (context) {
                            return AddSubjectToSchedDialog(courseId: widget.section['course']['id'],);
                          }
                        );
                        logger.d(selectedSubject);
                          if (selectedSubject != null) {
                          setState(() {
                            _curriculumList.add(selectedSubject);
                            _scheduleEntries.putIfAbsent(selectedSubject['id'], () => ScheduleEntry());
                          });
                          setState(() {});
                        }
                      }, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add),
                          const SizedBox(width: 10,),
                          Text(
                            'ADD SUBJECT', 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      )
                    ),
                  ],
                );
              }
            )
          ),
        ],
      ),
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
        _scheduleEntries[refId]?.startTimeController.text = '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
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
        _scheduleEntries[refId]?.endTimeController.text = '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }
  void _saveSchedules() async {
    for (var id in _scheduleEntries.keys) {
      final startTime = _scheduleEntries[id]?.startTimeController.text ?? '';
      final endTime = _scheduleEntries[id]?.endTimeController.text ?? '';
      final cycleId = _scheduleEntries[id]?.selectedCycle ?? 0;
      final instructorId = _scheduleEntries[id]?.selectedInstructor ?? 0;
      final daysList = _scheduleEntries[id]?.daysSelection ?? [];

      if (startTime.isEmpty || endTime.isEmpty || cycleId == 0 || instructorId == 0 || daysList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the fields!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final curriculumBySem = groupBy(_curriculumList, (s) => s['semester_no']);
    
    for (var semKey in curriculumBySem.keys) {
      final subjects = curriculumBySem[semKey];
      final visibleSubjects = subjects!.where((subj) => !_removedSubjectIds.contains(subj['id'])).toList();
      for (var subj in visibleSubjects) {
        if (_hasConflict(subj['id'], visibleSubjects)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Schedule conflict found in Semester $semKey. Please resolve conflicts before saving.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    for (var id in _scheduleEntries.keys) {
      final startTime = _scheduleEntries[id]!.startTimeController.text;
      final endTime = _scheduleEntries[id]!.endTimeController.text;
      final cycleId = _scheduleEntries[id]!.selectedCycle!;
      final instructorId = _scheduleEntries[id]!.selectedInstructor!;
      final sectionId = widget.section['id'];
      final daysList = _convertDaysSelection(_scheduleEntries[id]?.daysSelection ?? []);

      final error = await adminDBManager.addScheduleSection(
        startTime: startTime,
        endTime: endTime,
        cycleId: cycleId,
        curriculumId: id,
        sectionId: sectionId,
        instructorId: instructorId,
        days: daysList,
      );

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error $error'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    Navigator.pop(context);
  }

  List<String> _convertDaysSelection(List<bool> daysSelection) {
    final dayNames = ['M', 'T', 'W', 'Th', 'F', 'Sa'];
    return List.generate(daysSelection.length, (i) => daysSelection[i] ? dayNames[i] : null)
        .whereType<String>()
        .toList();
  }
}