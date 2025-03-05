import 'package:class_sched/admin_side/school_setup_navigation/dates_tabs/by_sem_tabs.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class CurrentDatesTab extends StatefulWidget {
  const CurrentDatesTab({super.key});

  @override
  State<CurrentDatesTab> createState() => _CurrentDatesTabState();
}

class _CurrentDatesTabState extends State<CurrentDatesTab> with SingleTickerProviderStateMixin {
  final adminDBManager = AdminDBManager();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  late TabController _semTabController;

  late int _semIdSelected;

  Stream<List<Map<String, dynamic>>>? streamSem;
  bool _isEditing = false;

  void initStreamSem() async {
    final acadYearMap = await adminDBManager.fetchAcadYearData(isCurrent: true);

    setState(() {
      streamSem = adminDBManager.database.from('semester').stream(primaryKey: ['id']).order('start_date').limit(3)
        .map((sems) => sems.map((sem) {
          final acadYear = acadYearMap[sem['academic_year_id']];
          return {
            'id' : sem['id'],
            'number' : sem['number'],
            'academic_year' : acadYear['academic_year'],
            'start_date' : sem['start_date'],
            'end_date' : sem['end_date'],
            'is_active' : acadYear['is_active']
          };
        }).toList()
      );
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    _semTabController = TabController(length: 3, vsync: this);
    _semIdSelected = 0;
    initStreamSem();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _semTabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: streamSem,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting || snapshot.data == null){
          return const Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasError){
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final semList = snapshot.data! as List<Map<String, dynamic>>;

        logger.d(semList);

        if (_semIdSelected == 0 && semList.isNotEmpty) {
          _semIdSelected = semList[2]['id'];
          _startDateController.text = semList[2]['start_date'];
          _endDateController.text = semList[2]['end_date'];
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Year'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(semList[2]['academic_year'], style: Theme.of(context).textTheme.bodyLarge,),
                        TextButton(
                          onPressed: (){}, 
                          child: const Text('Move to History', style: TextStyle(color: Colors.red,))
                        )
                      ],
                    ),
                    TabBar(
                      controller: _semTabController,
                      tabs: const [
                        Text('1st Semester'),
                        Text('2nd Semester'),
                        Text('Summer'),
                      ],
                      onTap: (value) {
                        if(value == 0) {
                          setState(() {
                            _semIdSelected = semList[2]['id'];
                            _startDateController.text =  semList[2]['start_date'];
                            _endDateController.text =  semList[2]['end_date'];
                          });
                        } else if(value == 1) {
                          setState(() {
                            _semIdSelected = semList[1]['id'];
                            _startDateController.text =  semList[1]['start_date'];
                            _endDateController.text =  semList[1]['end_date'];
                          });
                        } else if(value == 2) {
                          setState(() {
                            _semIdSelected = semList[0]['id'];
                            _startDateController.text =  semList[0]['start_date'];
                            _endDateController.text =  semList[0]['end_date'];
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: TextField(
                              controller: _startDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                labelStyle: Theme.of(context).textTheme.bodySmall,
                                prefixIcon: const Icon(Icons.calendar_month)
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              onTap: () async {
                                _selectStartDate();
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: TextField(
                              controller: _endDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                labelStyle: Theme.of(context).textTheme.bodySmall,
                                prefixIcon: const Icon(Icons.calendar_month)
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              onTap: () async {
                               _selectEndDate();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: Builder(
                        builder: (context) {
                          return TabBarView(
                            controller: _semTabController,
                            children: List.generate(3, (index) {
                              return BySemTabs(
                                semId: semList[2 - index]['id'], 
                                semNo: index + 1,
                              );
                            }),
                          );
                        }
                      ),
                    ),
                  ],
                ), 
              ],
            ),
          ),
        );
      }
    );
  }
  Future<void> _selectStartDate() async {
    DateTime? _picked = await showDatePicker(
      context: context, 
      firstDate: DateTime(2024), 
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineMedium: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14)
            ),
          ),
          child: child!,
        );
      }
    );
    if(_picked != null) {
      String newDate = _picked.toString().split(" ")[0];
      setState(() {
        _startDateController.text = newDate;
      });

      await adminDBManager.database
        .from('semester')
        .update({'start_date': newDate})
        .eq('id', _semIdSelected);
    }
  }
  Future<void> _selectEndDate() async {
    DateTime? _picked = await showDatePicker(
      context: context, 
      firstDate: DateTime(2024), 
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineMedium: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14)
            ),
          ),
          child: child!,
        );
      }
    );
    if(_picked != null) {
      String newDate = _picked.toString().split(" ")[0];
      setState(() {
        _endDateController.text = newDate;
      });

      await adminDBManager.database
        .from('semester')
        .update({'end_date': newDate})
        .eq('id', _semIdSelected);
    }
  }
}