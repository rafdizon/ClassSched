import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_course_dialog.dart';
import 'package:flutter/material.dart';

class SchoolSetupCourses extends StatefulWidget {
  const SchoolSetupCourses({super.key});

  @override
  State<SchoolSetupCourses> createState() => _SchoolSetupCoursesState();
}

class _SchoolSetupCoursesState extends State<SchoolSetupCourses> {
  final adminDBManager = AdminDBManager();
  var _selectedRows = [];
  var _isSort = false;
  int? _sortIndex;

  late Future? _coursesFromDB;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _coursesFromDB = adminDBManager.getCourses();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Courses Offered', style: Theme.of(context).textTheme.displayMedium,),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: (){
                      showDialog <Widget>(
                        context: context, 
                        barrierDismissible: false,
                        builder: (context) => AddCourseDialog(),
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
                  const SizedBox(width: 10,),
                  TextButton(
                    onPressed: () async { _selectedRows.isNotEmpty
                      ? showDialog(
                        context: context, 
                        builder: (context) {
                          return Dialog(
                            child: SizedBox(
                              height: 130,
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text('Are you sure to delete? This cannot be undone'),
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
                                            final error = await adminDBManager.deleteCourse(id: _selectedRows);
      
                                            if(error == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully!'), backgroundColor: Theme.of(context).colorScheme.primary,));
                                              Navigator.of(context).pop();
                                              setState(() {
                                                _selectedRows = [];
                                                _coursesFromDB = adminDBManager.getCourses();
                                              });
                                            }
                                            else {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                                            }
                                          }, 
                                          child: Text(
                                            'Delete',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.red, 
                                              fontWeight: FontWeight.bold
                                            )
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
                      )
                    : null;
                    },
                    style: TextButton.styleFrom(
                      fixedSize: const Size(90, 40),
                      backgroundColor: _selectedRows.isNotEmpty ? Colors.red : Colors.grey[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white,),
                        Text('Delete', style: TextStyle(color: Colors.white),)
                      ],
                    )
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _coursesFromDB = adminDBManager.getCourses();
                  });
                },
                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary,),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          FutureBuilder(
            future: _coursesFromDB,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              else if(snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final courseList = snapshot.data! as List<Map<String, dynamic>>;
              final courseData = courseList.map<DataRow>((course){
                return DataRow(
                  cells: [
                    DataCell(
                      Checkbox(
                        value: _selectedRows.contains(course['id']), 
                        onChanged: (value) {
                          setState(() {
                            if(value == true) {
                              _selectedRows.add(course['id']);
                            } else {
                              _selectedRows.remove(course['id']);
                            }
                            logger.d(_selectedRows);
                          });
                        }
                      ),
                    ),
                    DataCell(Text(course['name'], style: Theme.of(context).textTheme.bodySmall,)),
                    DataCell(Text(course['major'] ?? '', style: Theme.of(context).textTheme.bodySmall,)),
                    DataCell(Text(course['level'], style: Theme.of(context).textTheme.bodySmall,)),
                    DataCell(Text(course['short_form'], style: Theme.of(context).textTheme.bodySmall,)),
                  ]
                );
              }).toList();
              return Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                      sortAscending: _isSort,
                      sortColumnIndex: _sortIndex,
                      columns: [
                        const DataColumn(label: Text('')),
                        DataColumn(
                          label: const Text('Course Name'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _isSort = !_isSort;
                              _sortIndex = columnIndex;
      
                              courseList.sort((a,b) => _isSort ? a['name'].compareTo(b['name']) : b['name'].compareTo(a['name']));
                            });
                          },
                        ),
                        const DataColumn(label: Text('Major')),
                        const DataColumn(label: Text('Degree Level')),
                        DataColumn(
                          label: const Text('Short Form'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _isSort = !_isSort;
                              _sortIndex = columnIndex;
      
                              courseList.sort((a,b) => _isSort ? a['short_form'].compareTo(b['short_form']) : b['short_form'].compareTo(a['short_form']));
                            });
                          },
                        ),
                      ],
                      rows: courseData,
                    ),
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}