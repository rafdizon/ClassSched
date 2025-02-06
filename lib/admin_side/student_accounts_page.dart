import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_student_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class StudentAccountsPage extends StatefulWidget {
  const StudentAccountsPage({super.key});

  @override
  State<StudentAccountsPage> createState() => _StudentAccountsPageState();
}

class _StudentAccountsPageState extends State<StudentAccountsPage> {
  final adminDBManager = AdminDBManager();
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(70, 20, 70, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Accounts',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      hintText: 'Search',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: (){
                    showDialog <Widget>(
                      context: context, 
                      barrierDismissible: false,
                      builder: (context) => AddStudentDialog()
                    );
                  },
                  style: TextButton.styleFrom(
                    fixedSize: const Size(80, 40),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white,),
                      Text('Add', style: TextStyle(color: Colors.white),)
                    ],
                  )
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      
                    });
                  },
                  icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary,),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: LayoutBuilder(

                builder: (context, constraints) {
                  double screenHeight = constraints.maxHeight;
                  double screenWidth = constraints.maxWidth;

                  return FutureBuilder<Object>(
                    future: adminDBManager.getStudents(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      else if(snapshot.hasError){
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final studentData = (snapshot.data! as List<Map<String, dynamic>>).map<DataRow>((student){
                        return DataRow(
                          cells: [
                            DataCell(
                              IconButton(
                                onPressed: () {}, 
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary,)
                              )
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () async {
                                  final error = await adminDBManager.deleteUser(
                                    id: student['id'],
                                    email: student['email'].toString()
                                  );
                                  if(error != null && mounted){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully deleted student!'), backgroundColor: Theme.of(context).colorScheme.primary));
                                  }
                                }, 
                                icon: const Icon(Icons.delete, color: Colors.red,)
                              )
                            ),
                            DataCell(Text(student['student_no'] ?? '')),
                            DataCell(Text(student['first_name'] ?? '')),
                            DataCell(Text(student['middle_name'] ?? '')),
                            DataCell(Text(student['last_name'] ?? '')),
                            DataCell(Text(student['section']['year_level'].toString())),
                            DataCell(Text(student['section']['course']['name'] ?? '')),
                            DataCell(Text(student['is_regular'] ? 'Regular' : 'Irregular')),
                            DataCell(Text(student['email'] ?? '')),
                            DataCell(Text(student['sex'] ?? '')),
                          ]
                        );
                      }).toList();
                      logger.d(studentData);
                      return SizedBox(
                        height: screenHeight - 102,
                        width: screenWidth,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            controller: scrollController,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 30,
                                dataTextStyle: Theme.of(context).textTheme.bodySmall,
                                border: const TableBorder(top: BorderSide()),
                                columns: const [
                                  DataColumn(label: Text('')),
                                  DataColumn(label: Text('')),
                                  DataColumn(
                                    label: Text('Student ID'),
                                  ),
                                  DataColumn(
                                    label: Text('First Name'),
                                  ),
                                  DataColumn(
                                    label: Text('Middle Name'),
                                  ),
                                  DataColumn(
                                    label: Text('Last Name'),
                                  ),
                                  DataColumn(
                                    label: Text('Year'),
                                  ),
                                  DataColumn(
                                    label: Text('Course'),
                                  ),
                                  DataColumn(
                                    label: Text('Status'),
                                  ),
                                  DataColumn(
                                    label: Text('E-mail Address'),
                                  ),
                                  DataColumn(
                                    label: Text('Sex'),
                                  ),
                                ], 
                                rows: studentData
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  );
                }
              ),
            )
          ],
        ),
      )
    );
  }
}