import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/student_accounts_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_subject_to_sched_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';


class ScheduleEntry {
  int? scheduleId;
  dynamic selectedCycle;
  dynamic selectedInstructor;
  TextEditingController startTimeController;
  TextEditingController endTimeController;
  List<bool> daysSelection;

  ScheduleEntry({
    this.scheduleId,
    this.selectedCycle,
    this.selectedInstructor,
    TextEditingController? startTimeController,
    TextEditingController? endTimeController,
    List<bool>? daysSelection,
  })  : startTimeController = startTimeController ?? TextEditingController(),
        endTimeController = endTimeController ?? TextEditingController(),
        daysSelection = daysSelection ?? List.filled(6, false);
}

class EditIrregularSched extends StatefulWidget {
  final List<Map<String, dynamic>> schedule;
  final int semNo;
  const EditIrregularSched({Key? key, required this.schedule, required this.semNo})
      : super(key: key);


  @override
  State<EditIrregularSched> createState() => _EditIrregularSchedState();
}

class _EditIrregularSchedState extends State<EditIrregularSched> {
  final adminDBManager = AdminDBManager();
  Map<int, ScheduleEntry> _scheduleEntries = {};
  List<int> _removedSubjectIds = [];
  
  final _daysList = [Text("M"), Text("T"), Text("W"), Text("Th"), Text("F"), Text("Sa")];

  final _horizontalScroll = ScrollController();
  late Future<dynamic> _cyclesFuture;
  late Future<dynamic> _instructorsFuture;
  late List<Map<String, dynamic>> _curriculumList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _curriculumList = widget.schedule
      .where((sched) =>
          sched['schedule_time']['cycle'] != null &&
          sched['schedule_time']['cycle']['semester'] != null &&
          sched['schedule_time']['cycle']['semester']['number'] == widget.semNo)
      .toList();

    for (var sched in _curriculumList) {
      int key = sched['schedule_time']['id'] ?? sched['schedule_time']['curriculum']['id'];

      final entry = ScheduleEntry(
        scheduleId: sched['schedule_time']['id'],
        selectedCycle: sched['schedule_time']['cycle']['id'],
        selectedInstructor: sched['schedule_time']['instructor']['id'],
      );
      entry.startTimeController.text = _formatTime(sched['schedule_time']['start_time']);
      entry.endTimeController.text = _formatTime(sched['schedule_time']['end_time']);
      if (sched['schedule_time'].containsKey('days')) {
        List<dynamic> days = sched['schedule_time']['days'];
        entry.daysSelection = List.filled(6, false);
        final dayNames = ['M', 'T', 'W', 'Th', 'F', 'Sa'];
        for (int i = 0; i < dayNames.length; i++) {
          if (days.contains(dayNames[i])) {
            entry.daysSelection[i] = true;
          }
        }
      }
      _scheduleEntries[key] = entry;
    }
    _cyclesFuture = adminDBManager.getCycles();
    _instructorsFuture = adminDBManager.getinstructors();
    _isLoading = false;
  }

  @override
  void dispose() {
    _scheduleEntries.values.forEach((entry) {
      entry.startTimeController.dispose();
      entry.endTimeController.dispose();
    });
    super.dispose();
  }

  int _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return 0;
      final timePart = parts[0];
      final period = parts[1];
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
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      List<String> parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      String period = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return timeStr;
    }
  }


  bool _daysOverlap(List<bool> daysA, List<bool> daysB) {
    for (int i = 0; i < daysA.length; i++) {
      if (daysA[i] && daysB[i]) return true;
    }
    return false;
  }

  bool _hasConflict(int key, List<Map<String, dynamic>> visibleSubjects) {
    final currentEntry = _scheduleEntries[key];
    if (currentEntry == null ||
        currentEntry.startTimeController.text.isEmpty ||
        currentEntry.endTimeController.text.isEmpty ||
        currentEntry.selectedCycle == null) {
      return false;
    }
    int currentStart = _parseTime(currentEntry.startTimeController.text);
    int currentEnd = _parseTime(currentEntry.endTimeController.text);

    for (var subj in visibleSubjects) {
      int otherKey = (subj['schedule_time']['id'] != null) ? subj['schedule_time']['id'] : subj['schedule_time']['curriculum']['id'];
      if (otherKey == key) continue;
      final otherEntry = _scheduleEntries[otherKey];
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

  Future _selectStartTime({required int key}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _scheduleEntries[key]?.startTimeController.text =
            '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }

  Future _selectEndTime({required int key}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _scheduleEntries[key]?.endTimeController.text =
            '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }

  List<String> _convertDaysSelection(List<bool> daysSelection) {
    final dayNames = ['M', 'T', 'W', 'Th', 'F', 'Sa'];
    return List.generate(daysSelection.length, (i) => daysSelection[i] ? dayNames[i] : null)
        .whereType<String>()
        .toList();
  }

  Future _saveSchedules() async {
    for (var key in _scheduleEntries.keys) {
      final entry = _scheduleEntries[key]!;
      if (entry.startTimeController.text.isEmpty ||
          entry.endTimeController.text.isEmpty ||
          entry.selectedCycle == null ||
          entry.selectedInstructor == null ||
          entry.daysSelection.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the fields!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final visibleSubjects = _curriculumList.where((subj) {
      int key = (subj['schedule_time']['id'] != null) ? subj['schedule_time']['id'] : subj['schedule_time']['curriculum']['id'];
      return !_removedSubjectIds.contains(key);
    }).toList();

    for (var subj in visibleSubjects) {
      int key = subj['schedule_time']['id'] ?? subj['schedule_time']['curriculum']['id'];
      if (_hasConflict(key, visibleSubjects)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule conflict found. Please resolve conflicts before saving.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });
    for (var key in _scheduleEntries.keys) {
      final entry = _scheduleEntries[key]!;
      final startTime = entry.startTimeController.text;
      final endTime = entry.endTimeController.text;
      final cycleId = entry.selectedCycle;
      final instructorId = entry.selectedInstructor;
      final daysList = _convertDaysSelection(entry.daysSelection);
      final scheduleTimeId = entry.scheduleId;
      final curriculumId = key;
      dynamic error; 
      if(scheduleTimeId != null) {
        error = await adminDBManager.updateScheduleSection(
          schedId: scheduleTimeId,
          startTime: startTime,
          endTime: endTime,
          cycleId: cycleId,
          curriculumId: curriculumId,

          sectionId: widget.schedule.first['schedule_time']['section']['id'],
          instructorId: instructorId,
          days: daysList,
        );
      }
      else {
        error = await adminDBManager.addScheduleSection(
          startTime: startTime,
          endTime: endTime,
          cycleId: cycleId,
          curriculumId: curriculumId,
          sectionId: widget.schedule.first['schedule_time']['section']['id'],
          instructorId: instructorId,
          days: daysList,
        );
      }
      setState(() {
        _isLoading = false;
      });

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

    for (var removedId in _removedSubjectIds) {
      final error = await adminDBManager.deleteScheduleSection(id: removedId);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting schedule $removedId: $error'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => const StudentAccountsPage()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return BaseLayout(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Schedule',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextButton(
                  onPressed: _saveSchedules,
                  child: Text(
                    'Save Schedule',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            Text("Semester ${widget.semNo}"),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double desiredWidth = constraints.maxWidth < 1500 ? 1500 : constraints.maxWidth;
                  return Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    controller: _horizontalScroll,
                    child: SingleChildScrollView(
                      controller: _horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: desiredWidth,
                        child: ListView.builder(
                          itemCount: _curriculumList.length,
                          itemBuilder: (context, index) {
                            final subj = _curriculumList[index] as Map<String, dynamic>;
                            int key = subj['schedule_time']['id'] ?? subj['schedule_time']['curriculum']['id'];
                            if (_removedSubjectIds.contains(key)) return const SizedBox.shrink();
                            final scheduleEntry = _scheduleEntries.putIfAbsent(key, () => ScheduleEntry());
                            bool hasConflict = _hasConflict(key, _curriculumList);
                            return SizedBox(
                              height: 100,
                              child: Card(
                                color: hasConflict ? Colors.red[200] : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Table(
                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                    columnWidths: const {
                                      0: FractionColumnWidth(0.05),
                                      1: FractionColumnWidth(0.08),
                                      2: FractionColumnWidth(0.20),
                                      3: FractionColumnWidth(0.08),
                                      4: FractionColumnWidth(0.19),
                                      5: FractionColumnWidth(0.1333),
                                      6: FractionColumnWidth(0.1333),
                                      7: FractionColumnWidth(0.1333),
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
                                                    title: Text('Remove ${subj['schedule_time']['curriculum']['subject']['name']}?'),
                                                    content: const Text('This cannot be reversed'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          'Cancel',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Theme.of(context).colorScheme.primary,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _removedSubjectIds.add(key);
                                                            _scheduleEntries.remove(key);
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          'Delete',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                            ),
                                          ),
                                          Text(
                                            subj['schedule_time']['curriculum']['subject']['code'],
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          Text(
                                            subj['schedule_time']['curriculum']['subject']['name'],
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          // Cycle dropdown.
                                          FutureBuilder(
                                            future: _cyclesFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Text(snapshot.error.toString());
                                              }
                                              final cyclesList = snapshot.data as List<Map<String, dynamic>>;
                                              // Group cycles by semester number.
                                              final cyclesBySem = groupBy(cyclesList, (cycle) => cycle['semester']['number']);
                                              final cyclesForSem = cyclesBySem[widget.semNo] ?? [];
                                              final uniqueCycles = {
                                                for (var cycle in cyclesForSem) cycle['id'] : cycle
                                              }.values.toList();
                                              final cyclesDropdown = uniqueCycles.map((cycle) {
                                                return DropdownMenuItem(
                                                  value: cycle['id'],
                                                  child: Text(
                                                    cycle['cycle_no'],
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                );
                                              }).toList();
                                              if (!uniqueCycles.any((cycle) => cycle['id'] == scheduleEntry.selectedCycle)) {
                                                scheduleEntry.selectedCycle = null;
                                              }
                                              return SizedBox(
                                                height: 30,
                                                width: 30,
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
                                              );
                                            },
                                          ),
                                          // Days selection toggle buttons.
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
                                          // Start time field.
                                          Center(
                                            child: SizedBox(
                                              width: 140,
                                              child: TextField(
                                                controller: scheduleEntry.startTimeController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: "Start Time",
                                                  labelStyle: Theme.of(context).textTheme.bodySmall,
                                                  prefixIcon: Icon(
                                                    Icons.access_time,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                                style: Theme.of(context).textTheme.bodySmall,
                                                onTap: () => _selectStartTime(key: key),
                                              ),
                                            ),
                                          ),
                                          // End time field.
                                          Center(
                                            child: SizedBox(
                                              width: 140,
                                              child: TextField(
                                                controller: scheduleEntry.endTimeController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: "End Time",
                                                  labelStyle: Theme.of(context).textTheme.bodySmall,
                                                  prefixIcon: Icon(
                                                    Icons.access_time,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                                style: Theme.of(context).textTheme.bodySmall,
                                                onTap: () => _selectEndTime(key: key),
                                              ),
                                            ),
                                          ),
                                          // Instructor dropdown.
                                          FutureBuilder(
                                            future: _instructorsFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Text(snapshot.error.toString());
                                              }
                                              final instructorsList = snapshot.data as List<Map<String, dynamic>>;
                                              final instructorsDropdown = instructorsList.map((inst) {
                                                return DropdownMenuItem(
                                                  value: inst['id'],
                                                  child: Text(
                                                    '${inst['first_name']} ${inst['last_name']}',
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
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
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
            TextButton(
              onPressed: () async {
                final selectedSubject = await showDialog(
                  context: context, 
                  builder: (context) {
                    return AddSubjectToSchedDialog(courseId: widget.schedule.first['schedule_time']['curriculum']['course']['id']);
                  }
                );
                if (selectedSubject != null) {
                  setState(() {
                    Map<String, dynamic> newSubject = selectedSubject.containsKey('curriculum')
                    ? selectedSubject
                    : {
                        "id": selectedSubject["id"],
                        "schedule_time": {
                          "id": null,
                          "days": [],
                          "start_time": "",
                          "end_time": "",
                          "cycle": null,
                          "section": widget.schedule.first['schedule_time']?['section'],
                          // Add the curriculum key inside schedule_time:
                          "curriculum": {
                            "id": selectedSubject["id"],
                            "subject": selectedSubject["subject"],
                            "year_level": widget.schedule.first['schedule_time']?['section']?['year_level'] ?? 3,
                            "semester_no": widget.semNo,
                          }
                        },
                        "curriculum": {
                          "id": selectedSubject["id"],
                          "subject": selectedSubject["subject"],
                          "year_level": widget.schedule.first['schedule_time']?['section']?['year_level'] ?? 3,
                          "semester_no": widget.semNo,
                        }
                      };

                    _curriculumList.add(newSubject);
                    _scheduleEntries.putIfAbsent(newSubject['id'], () => ScheduleEntry(scheduleId: null));
                  });
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
        ),
      ),
    );
  }
}