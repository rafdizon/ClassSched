import 'package:class_sched/admin_side/instructor_sched_view/instructor_sched_view.dart';
import 'package:flutter/material.dart';

class InstructorDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> instructorMap;
  const InstructorDetailsDialog({super.key, required this.instructorMap});

  @override
  State<InstructorDetailsDialog> createState() => _InstructorDetailsDialogState();
}

class _InstructorDetailsDialogState extends State<InstructorDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.person, 
                    color: Theme.of(context).colorScheme.secondary,
                    size: 200,
                  ),
                  Table(
                    columnWidths: const {
                      0 : FractionColumnWidth(0.3),
                      1 : FractionColumnWidth(0.7)
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'Name: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.instructorMap['last_name']}, ${widget.instructorMap['first_name']} ${widget.instructorMap['middle_name'].toString().isNotEmpty ? widget.instructorMap['middle_name'].toString().substring(0,1) : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Email: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.instructorMap['email'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      const TableRow(
                        children: [
                          SizedBox(height: 20,),
                          SizedBox(height: 20,),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Status: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.instructorMap['is_full_time'] ? 'Full Time' : 'Part Time',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Sex: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.instructorMap['sex'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstructorSchedView(instructorId: widget.instructorMap['id']))
                  );
                }, 
                child: Text(
                  'View Schedule'
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}