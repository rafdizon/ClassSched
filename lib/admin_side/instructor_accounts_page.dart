import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_instructor_dialog.dart';
//import 'package:class_sched/ui_elements/add_instructor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class InstructorAccountsPage extends StatefulWidget {
  const InstructorAccountsPage({super.key});

  @override
  State<InstructorAccountsPage> createState() => _InstructorAccountsPageState();
}

class _InstructorAccountsPageState extends State<InstructorAccountsPage> {
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
                  'Instructor Accounts',
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
                      builder: (context) => AddInstructorDialog()
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
                    future: adminDBManager.getinstructors(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      else if(snapshot.hasError){
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final instructorData = (snapshot.data! as List<Map<String, dynamic>>).map<DataRow>((instructor){
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
                                    id: instructor['id'],
                                    email: instructor['email'].toString()
                                  );
                                  if(error != null && mounted){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully deleted instructor!'), backgroundColor: Theme.of(context).colorScheme.primary));
                                  }
                                }, 
                                icon: const Icon(Icons.delete, color: Colors.red,)
                              )
                            ),
                            DataCell(Text(instructor['instructor_no'] ?? '')),
                            DataCell(Text(instructor['first_name'] ?? '')),
                            DataCell(Text(instructor['middle_name'] ?? '')),
                            DataCell(Text(instructor['last_name'] ?? '')),
                            DataCell(Text(instructor['section']['year_level'].toString())),
                            DataCell(Text(instructor['section']['course']['name'] ?? '')),
                            DataCell(Text(instructor['is_regular'] ? 'Regular' : 'Irregular')),
                            DataCell(Text(instructor['email'] ?? '')),
                            DataCell(Text(instructor['sex'] ?? '')),
                          ]
                        );
                      }).toList();
                      logger.d(instructorData);
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
                                    label: Text('instructor ID'),
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
                                rows: instructorData
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