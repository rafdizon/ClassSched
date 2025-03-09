import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/schedule_manager/schedules_by_course_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

final logger = Logger();
class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  final adminDBManager = AdminDBManager();
  var _selectedNavigIndex = 0;
  late Future<List<dynamic>> _courseFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _courseFuture = adminDBManager.getCourses();
  }
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder(
            future: _courseFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
          
              final courses = snapshot.data as List<Map<String, dynamic>>;
              final courseRails = courses.map((course) {
                return NavigationRailDestination(
                  icon: const Icon(Icons.access_time),
                  label: Text(course['short_form'].toString())
                );
              }).toList();
              return Row(
                children: [
                  Container(
                    width: constraints.maxWidth * 0.177,
                    height: constraints.maxHeight,
                    color: Theme.of(context).colorScheme.tertiary,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Schedule Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: NavigationRail(
                            extended: true,
                            backgroundColor: Colors.transparent,
                            destinations: courseRails, 
                            selectedIndex: _selectedNavigIndex,
                            onDestinationSelected: (value) {
                              setState(() {
                                _selectedNavigIndex = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth - (constraints.maxWidth * 0.1777),
                    child: SchedulesByCoursePage(course: courses[_selectedNavigIndex],),
                  ),
                ],
              );
            }
          );
        }
      )
    );
  }
}