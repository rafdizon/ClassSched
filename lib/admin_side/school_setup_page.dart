import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/dashboard_page.dart';
import 'package:class_sched/admin_side/notification_page.dart';
import 'package:class_sched/admin_side/school_setup_navigation/school_setup_courses.dart';
import 'package:class_sched/admin_side/school_setup_navigation/school_setup_dates.dart';
import 'package:class_sched/admin_side/school_setup_navigation/school_setup_subjects.dart';
import 'package:flutter/material.dart';

class SchoolSetupPage extends StatefulWidget {
  const SchoolSetupPage({super.key});

  @override
  State<SchoolSetupPage> createState() => _SchoolSetupPageState();
}

class _SchoolSetupPageState extends State<SchoolSetupPage> {
  var _selectedNavigIndex = 0;
  final _navigationDestinations = const [SchoolSetupDates(), SchoolSetupCourses(), SchoolSetupSubjects()];

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Container(
                width: constraints.maxWidth * 0.177,
                height: constraints.maxHeight,
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('School Setup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      indent: 20,
                      endIndent: 20,
                    ),
                    Expanded(
                      child: NavigationRail(
                        extended: true,
                        backgroundColor: Colors.transparent,
                        indicatorColor: Theme.of(context).colorScheme.secondary,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.calendar_month_outlined, color: Colors.white), 
                            selectedIcon: Icon(Icons.calendar_month),
                            label: Text('Dates Settings', style: TextStyle(color: Colors.white),)
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.school_outlined, color: Colors.white,), 
                            selectedIcon: Icon(Icons.school),
                            label: Text('Courses Offered', style: TextStyle(color: Colors.white),)
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.book, color: Colors.white,), 
                            selectedIcon: Icon(Icons.book),
                            label: Text('Curricula', style: TextStyle(color: Colors.white),)
                          ),
                        ], 
                        selectedIndex: _selectedNavigIndex,
                        onDestinationSelected: (selected) {
                          setState(() {
                            _selectedNavigIndex = selected;
                          });
                        },
                      )
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: constraints.maxWidth - (constraints.maxWidth * 0.1777),
                child: _navigationDestinations[_selectedNavigIndex]
              )
            ],
          );
        },
      )
    );
  }
}