import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/services/password_generator.dart';
import 'package:flutter/material.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  var _dropdownValue;
  var _selectedYear;
  var _selectedSex;
  var _selectedStatus;
  final _yearList = [1,2,3,4];
  final _sexList = ['Male', 'Female',];
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _dropdownValue = null;
    _selectedYear = null;
    _selectedSex = null;
    _selectedStatus = null;
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a student: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(overflow: TextOverflow.ellipsis),),
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
                              'Student No.', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _studentNoController,
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
                              'E-mail Address', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _emailController,
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
                              'Password', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 30,
                                child: TextField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _passwordController.text = generatePassword();
                              }, 
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.refresh)
                            )
                          ],
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
                                logger.d(_dropdownValue);
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
                          
                              return DropdownButton<Object>(
                                hint: Text('Select a course...', style: Theme.of(context).textTheme.bodySmall,),
                                value: _dropdownValue,
                                items: coursesDropdownItems, 
                                onChanged: (newValue) {
                                  setState(() {
                                    _dropdownValue = newValue;
                                    logger.d(_dropdownValue);
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
                        if(_dropdownValue != null && _selectedYear != null && _selectedStatus != null && _emailController.text != '' && _passwordController.text != '' && _studentNoController.text != '' && _fnameController.text != '' && _lnameController.text != ''){
                          setState(() {
                            _isLoading = true;
                          });
                          final error = await AdminDBManager().registerStudent(
                            fName: _fnameController.text,
                            mName: _mnameController.text,
                            lName: _lnameController.text,
                            studentNo: _studentNoController.text,
                            email: _emailController.text,
                            pw: _passwordController.text,
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
        ),
      )
    );
  }
}