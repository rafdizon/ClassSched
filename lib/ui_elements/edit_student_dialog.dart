import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class EditStudentDialog extends StatefulWidget {
  final Map<String, dynamic> student;
  const EditStudentDialog({
    super.key,
    required this.student
  });

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  var _dropdownValue;
  var _selectedYear;
  var _selectedSex;
  var _selectedStatus;
  final _yearList = [1,2,3,4];
  final _sexList = ['Male', 'Female',];
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  late int tableId;

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _fnameController.text = widget.student['first_name'];
    _mnameController.text = widget.student['middle_name'];
    _lnameController.text = widget.student['last_name'];
    _dropdownValue = widget.student['course_id'] as int;
    _selectedYear = widget.student['year_level'] as int;
    _selectedSex = widget.student['sex'];
    _selectedStatus = widget.student['is_regular'];
    tableId = widget.student['id'] as int;
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 350,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit a student: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(overflow: TextOverflow.ellipsis),),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth()
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'First Name*', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _fnameController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                  
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Middle Name', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _mnameController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Last Name*', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _lnameController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                ],
              ),
              Table(
                columnWidths: const {
                  0: FractionColumnWidth(0.25),
                  1: FractionColumnWidth(0.05),
                  2: FractionColumnWidth(0.70),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      SizedBox(
                        height: 30,
                        child: DropdownButton(
                          hint: Text('Year Level...', style: Theme.of(context).textTheme.bodySmall,),
                          value: _selectedYear,
                          items: _yearList.map((year) {
                            return DropdownMenuItem(value: year, child: Text(year.toString(), style: Theme.of(context).textTheme.bodySmall,));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedYear = newValue;
                            });
                          },
                          isExpanded: true,
                        )
                      ),
                      const SizedBox(),
                      SizedBox(
                        height: 30,
                        child: FutureBuilder(
                          future: AdminDBManager().getCourses(),
                          builder: (context, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return const Center(child: CircularProgressIndicator(),);
                            }
                            else if(snapshot.hasError){
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            logger.d("INIT VALUE:$_dropdownValue");
                            final coursesList = snapshot.data as List<Map<String,dynamic>>;
                            final coursesDropdownItems = (snapshot.data as List<Map<String,dynamic>>).map((course){
                              return DropdownMenuItem(
                                value: course['id'],
                                child: Text(
                                  "${course['name'] ?? ''}  ${course['major'] ?? ''}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }).toList();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !coursesList.any((course) => course['id'] == _dropdownValue)) {
                                logger.d('LIST: $coursesList');
                                final matchingCourse = coursesList.firstWhere(
                                  (course) => course['id'] == _dropdownValue,
                                  orElse: null
                                );

                                setState(() {
                                  _dropdownValue = matchingCourse != null ? matchingCourse['id'] : null;
                                });
                              }
                            });
                            return DropdownButton<Object>(
                              hint: Text('Select a course...', style: Theme.of(context).textTheme.bodySmall,),
                              value: _dropdownValue,
                              items: coursesDropdownItems, 
                              onChanged: (newValue) {
                                setState(() {
                                  _dropdownValue = newValue;
                                });
                              },
                              selectedItemBuilder: (context) {
                                return coursesDropdownItems.map((DropdownMenuItem item) {
                                  final selectedCourse = coursesList.firstWhere(
                                    (course) => course['id'] == item.value,
                                    orElse: null
                                  );
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: double.infinity, 
                                      child: Text(
                                        "${selectedCourse['name']}  ${selectedCourse['major'] ?? ''}",
                                        overflow: TextOverflow.ellipsis,  
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              isExpanded: true,
                            );
                          }
                        ),
                        
                      ),
                    ],
                  ),
                ],
              ),
              Table(
                columnWidths: const {
                  0: FractionColumnWidth(0.45),
                  1: FractionColumnWidth(0.05),
                  2: FractionColumnWidth(0.50),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      SizedBox(
                        height: 30,
                        child: DropdownButton(
                          hint: Text('Select Sex...', style: Theme.of(context).textTheme.bodySmall,),
                          value: _selectedSex,
                          items: _sexList.map((sex) {
                            return DropdownMenuItem(value: sex, child: Text(sex, style: Theme.of(context).textTheme.bodySmall,));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSex = newValue;
                            });
                          },
                          isExpanded: true,
                        )
                      ),
                      const SizedBox(),
                      SizedBox(
                        height: 30,
                        child: DropdownButton(
                          hint: Text('Student Status...', style: Theme.of(context).textTheme.bodySmall,),
                          value: _selectedStatus,
                          items: ['Regular', 'Irregular'].map((status) {
                            return DropdownMenuItem(value: status, child: Text(status, style: Theme.of(context).textTheme.bodySmall,));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedStatus = newValue;
                            });
                          },
                          isExpanded: true,
                        )
                      ),
                    ]
                  )
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    }, 
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                  TextButton(
                    onPressed: () async {
                      if(_dropdownValue != null && _selectedYear != null && _selectedStatus != null && _fnameController.text != '' && _lnameController.text != ''){
                        setState(() {
                          _isLoading = true;
                        });
                        final error = await AdminDBManager().editStudent(
                          id: tableId,
                          fName: _fnameController.text,
                          mName: _mnameController.text,
                          lName: _lnameController.text,
                          year: _selectedYear as int,
                          courseID: _dropdownValue as int,
                          sex: _selectedSex,
                          isRegular: _selectedStatus == 'Regular' ? true : false,
                          context: context 
                        );
          
                        setState(() {
                          _isLoading = false;
                        });
                        
                        if(error != null && mounted){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                        }
                        else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully added student!'), backgroundColor: Theme.of(context).colorScheme.primary));
                        }
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill * required fields'), backgroundColor: Colors.red));
                      }
                    }, 
                    child: _isLoading 
                    ? const CircularProgressIndicator()
                    : Text(
                      'Save Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}