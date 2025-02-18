import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class EditInstructorDialog extends StatefulWidget {
  final Map<String, dynamic> instructor;
  const EditInstructorDialog({
    super.key,
    required this.instructor
  });

  @override
  State<EditInstructorDialog> createState() => _EditInstructorDialogState();
}

class _EditInstructorDialogState extends State<EditInstructorDialog> {
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
    _fnameController.text = widget.instructor['first_name'];
    _mnameController.text = widget.instructor['middle_name'];
    _lnameController.text = widget.instructor['last_name'];
    _selectedSex = widget.instructor['sex'];
    _selectedStatus = widget.instructor['is_full_time'] ? 'Full Time' : 'Part Time';
    tableId = widget.instructor['id'] as int;
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
              Text('Edit an instructor: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(overflow: TextOverflow.ellipsis),),
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
                          hint: Text('Instructor Status...', style: Theme.of(context).textTheme.bodySmall,),
                          value: _selectedStatus,
                          items: ['Full Time', 'Part Time'].map((status) {
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
                      if(_selectedStatus != null && _fnameController.text != '' && _lnameController.text != ''){
                        setState(() {
                          _isLoading = true;
                        });
                        final error = await AdminDBManager().editInstructor(
                          id: tableId,
                          fName: _fnameController.text,
                          mName: _mnameController.text,
                          lName: _lnameController.text,
                          sex: _selectedSex,
                          isFullTime: _selectedStatus == 'Full Time' ? true : false,
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