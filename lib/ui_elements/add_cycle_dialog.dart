import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCycleDialog extends StatefulWidget {
  final int cycleNo;
  final int semId;
  const AddCycleDialog({super.key, required this.cycleNo, required this.semId});

  @override
  State<AddCycleDialog> createState() => _AddCycleDialogState();
}

class _AddCycleDialogState extends State<AddCycleDialog> {
  var _isSequential = true;
  final _cycleNoController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final adminDBManager = AdminDBManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _cycleNoController.text = (widget.cycleNo + 1).toString();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a cycle', style: Theme.of(context).textTheme.bodyMedium,),
              const Divider(),
              Table(
                columnWidths: const {
                  0 : IntrinsicColumnWidth(),
                  1 : FlexColumnWidth()
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
                          child: Text('Cycle No.:', style: Theme.of(context).textTheme.bodySmall,)
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 30,
                              child: TextField(
                                readOnly: _isSequential,
                                controller: _cycleNoController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Checkbox(
                              value: _isSequential, 
                              onChanged: (value) {
                                setState(() {
                                  _isSequential = !_isSequential;
                                });
                              }
                            ),
                            Text(
                              'Sequential', 
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary
                              ),
                            ),
                          ],
                        ),
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
                          child: Text('Start Date:', style: Theme.of(context).textTheme.bodySmall,)
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _startDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, -5, 10, 0),
                            prefixIconConstraints: BoxConstraints(maxWidth: 50),
                            prefixIcon: SizedBox(
                              width: 20,
                              height: 20, 
                              child: Icon(Icons.calendar_month, size: 16),
                            )
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                          onTap: () async {
                            _selectStartDate();
                          },
                        ),
                      )
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('End Date:', style: Theme.of(context).textTheme.bodySmall,)
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _endDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, -5, 10, 0),
                            prefixIconConstraints: BoxConstraints(maxWidth: 50),
                            prefixIcon: SizedBox(
                              width: 20,
                              height: 20, 
                              child: Icon(Icons.calendar_month, size: 16),
                            )
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                          onTap: () async {
                            _selectEndDate();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
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
                    onPressed: () async{
                      if(_cycleNoController.text.isNotEmpty && _startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
                        final error = await adminDBManager.addCycle(
                          semId: widget.semId, 
                          cycleNo: int.parse(_cycleNoController.text), 
                          startDate: _startDateController.text, 
                          endDate: _endDateController.text
                        );
                        if(error != null && mounted){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                        }
                        else {
                          Navigator.of(context).pop(true);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully added cycle!'), backgroundColor: Theme.of(context).colorScheme.primary));
                          
                        }
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill all the fields'), backgroundColor: Colors.red));
                      }
                    }, 
                    child: Text(
                      'Add',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
    Future<void> _selectStartDate() async {
    DateTime? _picked = await showDatePicker(
      context: context, 
      firstDate: DateTime(2024), 
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineMedium: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14)
            ),
          ),
          child: child!,
        );
      }
    );
    if(_picked != null) {
      String newDate = _picked.toString().split(" ")[0];
      setState(() {
        _startDateController.text = newDate;
      });
    }
  }
  Future<void> _selectEndDate() async {
    DateTime? _picked = await showDatePicker(
      context: context, 
      firstDate: DateTime(2024), 
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineMedium: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14)
            ),
          ),
          child: child!,
        );
      }
    );
    if(_picked != null) {
      String newDate = _picked.toString().split(" ")[0];
      setState(() {
        _endDateController.text = newDate;
      });
    }
  }
}