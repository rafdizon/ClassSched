import 'package:class_sched/services/auth_service.dart';
import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final clientDBManager = ClientDBManager();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reloadPage,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FutureBuilder(
          future: clientDBManager.getCurrentStudentInfo(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(50),
                child: LinearProgressIndicator(),
              ),);
            }
            else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()),);
            }
            final studentData = snapshot.data as Map<String, dynamic>;
            
            return Column(
              children: [
                Center(
                  child: Icon(
                    Icons.person, 
                    size: 200,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                ),
                Text(
                  '${studentData['last_name']}, ${studentData['first_name']} ${studentData['middle_name'].toString().isNotEmpty ? studentData['middle_name'].toString().substring(0,1) : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  studentData['student_no'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Table(
                    columnWidths: const {
                      0 : FractionColumnWidth(0.3),
                      1 : FractionColumnWidth(0.7)
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'Course: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${studentData['section']['course']['name']} ${studentData['section']['course']['major']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 10,),
                          SizedBox(height: 10,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Year: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${studentData['section']['year_level']}${studentData['section']['year_level'] == 1 ? 'st' 
                            : studentData['section']['year_level'] == 2 ? 'nd'
                            : studentData['section']['year_level'] == 3 ? 'rd'
                            : 'th'} year',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 10,),
                          SizedBox(height: 10,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Status: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            studentData['is_regular'] ? 'Regular' : 'Irregular',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 10,),
                          SizedBox(height: 10,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Email: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            studentData['email'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 10,),
                          SizedBox(height: 10,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Sex: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            studentData['sex'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
              ]
            );
          }
        ),
      ),
    );
  }
  Future<void> _reloadPage() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {});
  }
}

