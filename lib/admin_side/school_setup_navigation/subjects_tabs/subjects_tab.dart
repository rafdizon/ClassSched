import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/ui_elements/add_subject_dialog.dart';
import 'package:flutter/material.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  final adminDBManager = AdminDBManager();
  Stream<List<Map<String, dynamic>>>? _streamSubjects;
  var _selectedRows = [];

  void initStreamSubjects() async {
    _streamSubjects = adminDBManager.database.from('subject')
    .stream(primaryKey: ['id']).eq('course_id', 0)
    .map((subjects) => subjects.map((subject) {
      return {
        'id' : subject['id'],
        'name' : subject['name'],
        'units' : subject['units'],
        'code' : subject['code'],
      };
    }).toList() );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initStreamSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton(
              onPressed: (){
                showDialog <Widget>(
                  context: context, 
                  barrierDismissible: false,
                  builder: (context) => const AddSubjectDialog(),
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
                                      final error = await adminDBManager.deleteSubject(id: _selectedRows);

                                      if(error == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully!'), backgroundColor: Theme.of(context).colorScheme.primary,));
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _selectedRows = [];
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
        const SizedBox(height: 10,),
        StreamBuilder(
          stream: _streamSubjects, 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            else if(snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            final subjectsList = snapshot.data as List<Map<String, dynamic>>; 
            final subjectRows = subjectsList.map((subjects) {
              return DataRow(
                selected: _selectedRows.contains(subjects['id']),
                onSelectChanged: (selected) {
                  setState(() {
                    if(selected == true) {
                      _selectedRows.add(subjects['id']);
                    }
                    else {
                      _selectedRows.remove(subjects['id']);
                    }
                  });
                },
                cells: [
                  DataCell(Text(subjects['code'], style: Theme.of(context).textTheme.bodySmall)),
                  DataCell(Text(subjects['name'], maxLines: 1, style: Theme.of(context).textTheme.bodySmall,)),
                  DataCell(Text(subjects['units'].toString(), style: Theme.of(context).textTheme.bodySmall)),
                ],
              );
            }).toList();
            return Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                    showCheckboxColumn: true,
                    columns: const [
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Units')),
                    ], 
                    rows: subjectRows
                  ),
                ),
              ),
            );
          }
        ),
      ],
    );
  }
}