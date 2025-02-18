import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Stream<List<Map<String, dynamic>>>? streamSem;
  bool _isEditing = false;

  @override
  void initState() {
    // TODO: implement initState
    _semTabController = TabController(length: 3, vsync: this);
    streamSem = adminDBManager.database.from('semester').stream(primaryKey: ['id']).order('start_date').limit(2)
      .map(((sems) => sems.map((sem) {
        return {
          'id' : sem['id'],
          'number' : sem['number'],
          'academic_year' : sem['academic_year'],
          'start_date' : sem['start_date'],
          'end_date' : sem['end_date'],
        };
      }).toList()
    ));
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Academic Year'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(semList[0]['academic_year'], style: Theme.of(context).textTheme.bodyLarge,),
                      TextButton(
                        onPressed: (){}, 
                        child: Text('Move to History', style: TextStyle(color: Colors.red,))
                      )
                    ],
                  ),
                  TabBar(
                    controller: _semTabController,
                    tabs: const [
                      Text('1st Semester'),
                      Text('2nd Semester'),
                      Text('Summer'),
                    ]
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
                              prefixIcon: Icon(Icons.calendar_month)
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            onTap: () async {
                              _selectDate(isStart: true);
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: TextField(
                            controller: _endDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                              prefixIcon: Icon(Icons.calendar_month)
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            onTap: () async {
                              _selectDate(isStart: true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ), 
            ],
          ),
        );
      }
    );
  }
  Future<void> _selectDate({required bool isStart}) async {
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
    if(isStart && _picked != null) {
      setState(() {
        _startDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }
}