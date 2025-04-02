import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class SelectClassDialog extends StatefulWidget {
  final int semNo;
  final List<Map<String, dynamic>> currentScheds;
  const SelectClassDialog({super.key, required this.semNo, required this.currentScheds});

  @override
  State<SelectClassDialog> createState() => _SelectClassDialogState();
}

class _SelectClassDialogState extends State<SelectClassDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  bool _hasConflict(List<Map<String, dynamic>> subjects) {
    for (final currentSched in widget.currentScheds) {
      final Map<String, dynamic> currentTime = currentSched['schedule_time'];
      
      for (final subject in subjects) {
        if (currentTime['cycle']['cycle_no'] != subject['cycle']['cycle_no']) {
          continue;
        }
        
        final List currentDays = currentTime['days'];
        final List subjectDays = subject['days'];
        final bool daysOverlap = currentDays.any((day) => subjectDays.contains(day));
        if (!daysOverlap) {
          continue;
        }
        
        final int currentStart = _parseTime(currentTime['start_time']);
        final int currentEnd = _parseTime(currentTime['end_time']);
        final int subjectStart = _parseTime(subject['start_time']);
        final int subjectEnd = _parseTime(subject['end_time']);
        
        if (currentStart < subjectEnd && subjectStart < currentEnd) {
          return true;
        }
      }
    }
    return false; 
  }

  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Schedule',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      hintText: 'Search',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: FutureBuilder(
                future: AdminDBManager().getAllClasses(semNo: widget.semNo), 
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  else if(!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Failed to load data, check internet connection'));
                  }
                  final classes = snapshot.data as List<Map<String, dynamic>>;
                  final filteredClasses = classes.where((c) {
                    final schedule = {
                      'start_time': c['start_time'],
                      'end_time': c['end_time'],
                      'days': c['days'],
                      'cycle': c['cycle'],
                    };

                    if (_hasConflict([schedule])) return false;
                    if (_searchQuery.isEmpty) return true;

                    final subjectCode = c['curriculum']['subject']['code'].toString().toLowerCase();
                    final subjectName = c['curriculum']['subject']['name'].toString().toLowerCase();
                    final courseShortForm = c['section']['course']['short_form'].toString().toLowerCase();
                    final query = _searchQuery.toLowerCase();

                    return subjectCode.contains(query) ||
                          subjectName.contains(query) ||
                          courseShortForm.contains(query);
                  }).toList();


                  final classItems = filteredClasses.map((c) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, c);
                        },
                        child: Card(
                          child: SizedBox(
                            height: 60,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Table(
                                  columnWidths: const {
                                    0 : FractionColumnWidth(0.10),
                                    1 : FractionColumnWidth(0.20),
                                    2 : FractionColumnWidth(0.10),
                                    3 : FractionColumnWidth(0.05),
                                    4 : FractionColumnWidth(0.15),
                                    5 : FractionColumnWidth(0.15),
                                    6 : FractionColumnWidth(0.15),
                                    7 : FractionColumnWidth(0.10),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Text(
                                          c['curriculum']['subject']['code'],
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          c['curriculum']['subject']['name'],
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${c['section']['course']['short_form']}-${c['section']['year_level']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          c['cycle']['cycle_no'],
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${c['cycle']['start_date']} to ${c['cycle']['end_date']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${c['start_time']} to ${c['end_time']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          c['days'].join(', '),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${c['instructor']['first_name']} ${c['instructor']['last_name']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList();
              
                  return ListView.builder(
                    itemCount: classItems.length,
                    itemBuilder: (context, index) {
                      return classItems[index];
                    }
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}