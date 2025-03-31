import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_instructor_dialog.dart';
import 'package:class_sched/ui_elements/edit_instructor_dialog.dart';
import 'package:class_sched/ui_elements/instructor_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class InstructorAccountsPage extends StatefulWidget {
  final String? instEmail;
  const InstructorAccountsPage({super.key, this.instEmail});

  @override
  State<InstructorAccountsPage> createState() => _InstructorAccountsPageState();
}

class _InstructorAccountsPageState extends State<InstructorAccountsPage> {
  final adminDBManager = AdminDBManager();
  final scrollController = ScrollController();
  bool sort = false;
  int sortIndex = 0;
  Stream<List<Map<String, dynamic>>>? streamInstructors;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchQuery = widget.instEmail != null ? widget.instEmail! : '';
    _searchController.text =_searchQuery;
    streamInstructors = adminDBManager.database.from('instructor').stream(primaryKey: ['id']).map(((instructors) => instructors.map((instructor)
        {
          return {
            'id' : instructor['id'],
            'first_name' : instructor['first_name'],
            'middle_name' : instructor['middle_name'],
            'last_name' : instructor['last_name'],
            'is_full_time' : instructor['is_full_time'],
            'email' : instructor['email'],
            'sex' : instructor['sex'],
          };
        }).toList()
      )
    );
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
                  'Instructor Accounts',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      hintText: 'Search',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
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

                  return StreamBuilder<Object>(
                    stream: streamInstructors,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting || snapshot.data == null){
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      else if(snapshot.hasError){
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      logger.d(snapshot.data);
                      final instructorList = snapshot.data! as List<Map<String, dynamic>>;
                      final filteredInstructor = instructorList.where((instructor) {
                        if(_searchQuery.isEmpty) return true;
                        final query = _searchQuery.toLowerCase();

                        return(instructor['first_name']?.toString().toLowerCase().contains(query) ?? false) 
                        || (instructor['last_name']?.toString().toLowerCase().contains(query) ?? false) 
                        || (instructor['email']?.toString().toLowerCase().contains(query) ?? false);
                      }).toList();
                      final instructorData = filteredInstructor.map<DataRow>((instructor){
                        return DataRow(
                          onSelectChanged: (selected) {
                            if (selected ?? false) {
                              showDialog(
                                context: context, 
                                builder: (context) => InstructorDetailsDialog(instructorMap: instructor)
                              );
                            }
                          },
                          cells: [
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context, 
                                    barrierDismissible: false,
                                    builder: (context) => EditInstructorDialog(instructor: instructor)
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
                                                          id: instructor['id'],
                                                          email: instructor['email'].toString(),
                                                          isStudent: false
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
                            DataCell(Text(instructor['first_name'] ?? '')),
                            DataCell(Text(instructor['middle_name'] ?? '')),
                            DataCell(Text(instructor['last_name'] ?? '')),
                            DataCell(Text(instructor['email'] ?? '')),
                            DataCell(Text(instructor['sex'] ?? '')),
                            DataCell(Text(instructor['is_full_time'] ? 'Full Time' : 'Part Time')),
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
                              child: FittedBox(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: screenWidth),
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
                                  
                                            instructorList.sort((a,b) => sort ? a['last_name'].compareTo(b['last_name']) : b['last_name'].compareTo(a['last_name']));
                                          });
                                        }
                                      ),
                                      const DataColumn(
                                        label: Text('E-mail Address'),
                                      ),
                                      const DataColumn(
                                        label: Text('Sex'),
                                      ),
                                      const DataColumn(
                                        label: Text('Status'),
                                      ),
                                    ], 
                                    rows: instructorData
                                  ),
                                ),
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