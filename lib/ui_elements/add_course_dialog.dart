import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final adminDBManager = AdminDBManager();
  String? _selectedLevel;
  final _courseNameController = TextEditingController();
  final _shortFormController = TextEditingController();
  final _majorController = TextEditingController();

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 350,
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a Course', style: Theme.of(context).textTheme.bodyMedium,),
                const Divider(),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0 : IntrinsicColumnWidth(),
                    1 : FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 50,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Course Name*', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _courseNameController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Short Form*', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _shortFormController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 50,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Major', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _majorController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 50,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Level*', 
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: DropdownButton(
                            isExpanded: true,
                            hint: const Text('Select Education Level'),
                            value: _selectedLevel,
                            items: ['Diploma', 'Bachelor\'s', 'Master\'s', 'Doctoral'].map((level) {
                              return DropdownMenuItem(value: level, child: Text(level, style: Theme.of(context).textTheme.bodySmall));
                            }).toList(), 
                            onChanged: (newValue) {
                              setState(() {
                                _selectedLevel = newValue;
                              });
                            }
                          )
                        )
                      ]
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '* Required Fields', 
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.red
                  ),
                ),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red
                        ),
                      )
                    ),
                    TextButton(
                      onPressed: () async {
                        if(_courseNameController.text != '' && _selectedLevel != null && _shortFormController.text != '') {
                          setState(() {
                            _isLoading = true;
                          });
                          final error = await adminDBManager.addCourse(
                              name: _courseNameController.text, 
                              level: _selectedLevel, 
                              shortForm: _shortFormController.text,
                              major: _majorController.text
                          );

                          setState(() {
                            _isLoading = false;
                          });

                          if(error != null && mounted){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                          }
                          else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully added course!'), backgroundColor: Theme.of(context).colorScheme.primary));
                          }
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill * required fields'), backgroundColor: Colors.red));
                        }
                      }, 
                      child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                        'Add',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary
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