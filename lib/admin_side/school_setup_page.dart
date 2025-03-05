import 'package:class_sched/admin_side/base_layout.dart';
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
                color: Theme.of(context).colorScheme.tertiary,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('School Setup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: NavigationRail(
                        extended: true,
                        backgroundColor: Colors.transparent,
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.calendar_month_outlined, color: Colors.grey[800],), 
                            selectedIcon: const Icon(Icons.calendar_month),
                            label: Text('Dates Settings', style: TextStyle(color: Colors.grey[800]),)
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.school_outlined, color: Colors.grey[800],), 
                            selectedIcon: const Icon(Icons.school),
                            label: Text('Courses Offered', style: TextStyle(color: Colors.grey[800]),)
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.book, color: Colors.grey[800],), 
                            selectedIcon: const Icon(Icons.book),
                            label: Text('Subjects Offered', style: TextStyle(color: Colors.grey[800]),)
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