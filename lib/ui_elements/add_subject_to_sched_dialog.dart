import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class AddSubjectToSchedDialog extends StatefulWidget {
  final int courseId;
  const AddSubjectToSchedDialog({super.key, required this.courseId});

  @override
  State<AddSubjectToSchedDialog> createState() => _AddSubjectToSchedDialogState();
}

class _AddSubjectToSchedDialogState extends State<AddSubjectToSchedDialog> {
  final adminDBManager = AdminDBManager();
  bool _isHovered = false;

  late Future<dynamic> _futureCurriculum;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureCurriculum = adminDBManager.getCurriculum(courseId: widget.courseId);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder(
        future: _futureCurriculum, 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final curriculumList = snapshot.data as List<Map<String, dynamic>>;
          final subjectItems = curriculumList.map((subj) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: (){
                  logger.i(subj);
                  Navigator.pop(context, subj);
                },
                child: Card(
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Table(
                          columnWidths: const {
                            0 : FractionColumnWidth(0.20),
                            1 : FractionColumnWidth(0.60),
                            2 : FractionColumnWidth(0.20),
                          },
                          children: [
                            TableRow(
                              children: [
                                Text(subj['subject']['code'], style: Theme.of(context).textTheme.bodySmall,),
                                Text(subj['subject']['name'], style: Theme.of(context).textTheme.bodySmall,),
                                Text('${subj['subject']['units'].toString()} units', style: Theme.of(context).textTheme.bodySmall,),
                              ]
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList();
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: subjectItems.length,
              itemBuilder: (context, index) {
                return subjectItems[index];
              }
            ),
          );
        }
      ),
    );
  }
}