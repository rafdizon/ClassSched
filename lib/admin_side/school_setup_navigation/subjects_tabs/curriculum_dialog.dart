import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:logger/web.dart';
import 'package:data_table_2/data_table_2.dart';

final logger = Logger();
class CurriculumDialog extends StatefulWidget {
  final int courseId;
  const CurriculumDialog({super.key, required this.courseId});

  @override
  State<CurriculumDialog> createState() => _CurriculumDialogState();
}

class _CurriculumDialogState extends State<CurriculumDialog> {
  final adminDBManager = AdminDBManager();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: adminDBManager.getCurriculum(courseId: widget.courseId), 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
        
            final curriculumList = snapshot.data as List<Map<String, dynamic>>;
            final groupedCurriculum = groupBy(curriculumList, (c) => c['year_level']).map((year, list) => MapEntry(year, groupBy(list, (c) => c['semester_no'])));
            
            
            return ListView.builder(
              itemCount: groupedCurriculum.keys.length,
              itemBuilder: (context, index) {
                final yearKey = groupedCurriculum.keys.elementAt(index);
                final semesterMap = groupedCurriculum[yearKey];
        
                return Column(
                  children: [
                    Text('Year $yearKey'),
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                      ),
                      shrinkWrap: true,
                      itemCount: semesterMap!.keys.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, semIndex) {
                        final semKey = semesterMap.keys.elementAt(semIndex);
                        final subjects = semesterMap[semKey];
                    
                        List<DataRow> rows = subjects!.map((subj) {
                          return DataRow(
                            cells: [
                              DataCell(Text(subj['subject']['name'], style: Theme.of(context).textTheme.bodySmall,)), 
                              DataCell(Text(subj['subject']['code'], style: Theme.of(context).textTheme.bodySmall,)), 
                              DataCell(Text(subj['subject']['units'].toString(), style: Theme.of(context).textTheme.bodySmall,)),
                            ]
                          );
                        }).toList();
                    
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Semester $semKey'),
                            SizedBox(
                              width: 700,
                              height: 500,
                              child: DataTable2(
                                headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                                columns: const [
                                  DataColumn2(label: Text('Name'), size: ColumnSize.L),
                                  DataColumn2(label: Text('Code'), fixedWidth: 100),
                                  DataColumn2(label: Text('Units'), fixedWidth: 100),
                                ], 
                                rows: rows
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }
}