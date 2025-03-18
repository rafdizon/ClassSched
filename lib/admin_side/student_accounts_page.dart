import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_student_dialog.dart';
import 'package:class_sched/ui_elements/edit_student_dialog.dart';
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
  bool sort = false;
  int sortIndex = 0;
  Stream<List<Map<String, dynamic>>>? streamStudents;

  void initStreamStudents() async {
    final sectionMap = await adminDBManager.fetchSectionData();
    
    setState(() {
      streamStudents = adminDBManager.database.from('student').stream(primaryKey: ['id']).map((students) => students.map((student) 
      {
        final section = sectionMap[student['section_id']];
        return {
          'id' : student['id'], 
          'student_no' : student['student_no'], 
          'first_name' : student['first_name'], 
          'middle_name' : student['middle_name'], 
          'last_name' : student['last_name'], 
          'year_level' : section?['year_level'] as int? ?? 0, 
          'course' : section?['course']?['name'] ?? '',
          'course_id' : section?['course']?['id'] ?? 0,
          'is_regular' : student['is_regular'] ? 'Regular' : 'Irregular', 
          'email' : student['email'], 
          'sex' : student['sex'],
        };
      }).toList());
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initStreamStudents();
  }

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
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      hintText: 'Search',
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 1,
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

                  return StreamBuilder<Object>(
                    stream: streamStudents,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting || snapshot.data == null){
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      else if(snapshot.hasError){
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      logger.d(snapshot.data);
                      final studentList = snapshot.data! as List<Map<String, dynamic>>;
                      final studentData = studentList.map<DataRow>((student){
                        return DataRow(
                          cells: [
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context, 
                                    barrierDismissible: false,
                                    builder: (context) => EditStudentDialog(student: student)
                                  );
                                }, 
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary,)
                              )
                            ),
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context, 
                                    builder: (context) {
                                      return Dialog(
                                        child: SizedBox(
                                          height: 180,
                                          width: 150,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text('Are you sure to delete? This cannot be undone'),
                                                const Spacer(),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      }, 
                                                      child: Text(
                                                        'Cancel',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                                                      )
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        final error = await adminDBManager.deleteUser(
                                                          id: student['id'],
                                                          email: student['email'].toString(),
                                                          isStudent: true
                                                        );
                                                        if(error != null && mounted){
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                                                        }
                                                        else {
                                                          setState(() {
                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully deleted student!'), backgroundColor: Theme.of(context).colorScheme.primary));
                                                          });
                                                        }
                                                        Navigator.of(context).pop();
                                                      }, 
                                                      child: Text(
                                                        'Delete',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)
                                                      )
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  );
                                }, 
                                icon: const Icon(Icons.delete, color: Colors.red,)
                              )
                            ),
                            DataCell(Text(student['student_no'] ?? '')),
                            DataCell(Text(student['first_name'] ?? '')),
                            DataCell(Text(student['middle_name'] ?? '')),
                            DataCell(Text(student['last_name'] ?? '')),
                            DataCell(Text(student['year_level'].toString() ?? '0')),
                            DataCell(Text(student['course'] ?? '')),
                            DataCell(Text(student['is_regular'])),
                            DataCell(Text(student['email'] ?? '')),
                            DataCell(Text(student['sex'] ?? '')),
                          ]
                        );
                      }).toList();
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
                                sortAscending: sort,
                                sortColumnIndex: sortIndex,
                                columnSpacing: 30,
                                dataTextStyle: Theme.of(context).textTheme.bodySmall,
                                headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                                columns: [
                                  const DataColumn(label: Text('')),
                                  const DataColumn(label: Text('')),
                                  const DataColumn(
                                    label: Text('Student ID'),
                                  ),
                                  const DataColumn(
                                    label: Text('First Name'),
                                  ),
                                  const DataColumn(
                                    label: Text('Middle Name'),
                                  ),
                                  DataColumn(
                                    label: const Text('Last Name'),
                                    onSort: (columnIndex, ascending) {
                                      setState(() {
                                        sort = !sort;
                                        sortIndex = columnIndex;

                                        studentList.sort((a,b) => sort ? a['last_name'].compareTo(b['last_name']) : b['last_name'].compareTo(a['last_name']));
                                      });
                                    }
                                  ),
                                  DataColumn(
                                    label: Text('Year'),
                                    onSort: (columnIndex, ascending) {
                                      setState(() {
                                        sort = !sort;
                                        sortIndex = columnIndex;

                                        studentList.sort((a,b) => sort ? a['year_level'].compareTo(b['year_level']) : b['year_level'].compareTo(a['year_level']));
                                      });
                                    }
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