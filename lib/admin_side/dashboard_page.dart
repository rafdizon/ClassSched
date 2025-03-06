import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/instructor_accounts_page.dart';
import 'package:class_sched/admin_side/school_setup_page.dart';
import 'package:class_sched/admin_side/student_accounts_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/dashboard_menu_item.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final adminDBManager = AdminDBManager();
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(70, 20, 70, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Row(
              children: [
                Card(
                  child: FutureBuilder(
                    future: adminDBManager.database.from('student').count(), 
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(),);
                      } else if(snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      final studentCount = snapshot.data as int;

                      return ListTile(
                        leading: Icon(Icons.groups_sharp),
                        title: Text(studentCount.toString()),
                        subtitle: Text('Students Enrolled'),
                      );

                    }
                  )
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double screenHeight = constraints.maxHeight;
                  double screenWidth = constraints.maxWidth;
              
                  return SizedBox(
                    height: screenHeight - 102,
                    width: screenWidth,
                    child: GridView.count(
                      crossAxisCount: screenWidth > 500 ? 2 : 1,
                      crossAxisSpacing: 50,
                      childAspectRatio: 4,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const StudentAccountsPage()
                              )
                            );
                          },
                          child: const DashboardMenuItem(
                            icon: Icons.person, 
                            description: 'Manage students\' accounts', 
                            label: 'Student Accounts'
                          )
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const InstructorAccountsPage()
                              )
                            );
                          },
                          child: const DashboardMenuItem(
                            icon: Icons.group, 
                            description: 'Manage instructors\' accounts', 
                            label: 'Instructor Accounts'
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            
                          },
                          child: const DashboardMenuItem(
                            icon: Icons.calendar_month, 
                            description: 'Manage schedules of students and instructors', 
                            label: 'Adding, Deleting, and Updating Schedule'
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const SchoolSetupPage()
                              )
                            );
                          },
                          child: const DashboardMenuItem(
                            icon: Icons.school, 
                            description: 'Manage school system (dates, courses, etc.)', 
                            label: 'School Setup Management'
                          ),
                        ),
                        
                      ],
                    ),
                  );
                },
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}