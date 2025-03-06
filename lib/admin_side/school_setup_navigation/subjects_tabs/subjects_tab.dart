import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  final adminDBManager = AdminDBManager();
  Stream<List<Map<String, dynamic>>>? _streamSubjects;
  final _selectedRows = [];

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
    return StreamBuilder(
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
        return SingleChildScrollView(
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
        );
      }
    );
  }
}