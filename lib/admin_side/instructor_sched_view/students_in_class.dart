import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class StudentsInClass extends StatefulWidget {
  final int schedId;
  const StudentsInClass({super.key, required this.schedId});

  @override
  State<StudentsInClass> createState() => _StudentsInClassState();
}

class _StudentsInClassState extends State<StudentsInClass> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Students Enrolled', style: Theme.of(context).textTheme.bodyLarge,),
            Divider(color: Theme.of(context).colorScheme.primary,),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: FutureBuilder(
                  future: AdminDBManager().getStudentsInClass(schedId: widget.schedId), 
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(),);
                    }
                    else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('Please Check internet Connection'));
                    }
                    final studentsList = snapshot.data as List<Map<String, dynamic>>;
                
                    final studentRows = studentsList.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text('${student['student']['last_name']}, ${student['student']['first_name']}', style: Theme.of(context).textTheme.bodySmall,)
                          ),
                          DataCell(Text(student['student']['student_no'], style: Theme.of(context).textTheme.bodySmall,)),
                          DataCell(Text(student['student']['is_regular'] ? 'Regular' : 'Irregular', style: Theme.of(context).textTheme.bodySmall,)),
                          DataCell(Text(student['student']['email'], style: Theme.of(context).textTheme.bodySmall,)),
                          DataCell(Text(student['student']['sex'], style: Theme.of(context).textTheme.bodySmall,)),
                          DataCell(Text('${student['student']['section']['course']['short_form']}-${student['student']['section']['year_level']}', style: Theme.of(context).textTheme.bodySmall,)),
                        ]
                      );
                    }).toList();
                
                    return SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                        columns:  [
                          DataColumn(label: Text('Name', style: Theme.of(context).textTheme.bodySmall,)),
                          DataColumn(label: Text('Student No', style: Theme.of(context).textTheme.bodySmall,)),
                          DataColumn(label: Text('Status', style: Theme.of(context).textTheme.bodySmall,)),
                          DataColumn(label: Text('Email', style: Theme.of(context).textTheme.bodySmall,)),
                          DataColumn(label: Text('Sex', style: Theme.of(context).textTheme.bodySmall,)),
                          DataColumn(label: Text('Section', style: Theme.of(context).textTheme.bodySmall,)),
                        ], 
                        rows: studentRows
                      ),
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}