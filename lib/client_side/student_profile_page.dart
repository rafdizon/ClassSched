import 'package:class_sched/dummy_data.dart';
import 'package:flutter/material.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentName = students[0]['first_name'].toString() + ' ' + students[0]['last_name'].toString();
    final studentId = students[0]['student_id'].toString();
    final studentCourse = students[0]['course'].toString();
    final studentYear = students[0]['year'] as int;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.person_2_outlined), 
                selectedIcon: Icon(Icons.person_2),
                label: Text('Profile')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Schedule')
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('About')
              ),
            ], 
            selectedIndex: 0
          ),
          //SizedBox(width: 80,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Image(
                image: AssetImage('assets/images/logo1.png'),
              ),
              SizedBox(height: 50,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 250,
                        width: 200,
                        child: Placeholder(),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        studentId,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Student ID',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  SizedBox(width: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Student Name',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: 10,),
                      Text(
                        studentCourse,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Course',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: 10,),
                      Text(
                        '$studentYear${studentYear == 1 ? 'st' 
                        : studentYear == 2 ? 'nd' 
                        : studentYear == 3 ? 'rd' 
                        : 'th'} Year',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Year Level',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}