import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/schedule_manager/schedule_manager_gate.dart';
import 'package:class_sched/admin_side/schedule_manager/add_schedule_to_section_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';


class SchedulesByCoursePage extends StatefulWidget {
  final Map<String, dynamic> course;
  const SchedulesByCoursePage({super.key, required this.course});

  @override
  State<SchedulesByCoursePage> createState() => _SchedulesByCoursePageState();
}

class _SchedulesByCoursePageState extends State<SchedulesByCoursePage> {
  final logger = Logger();
  final adminDBManager = AdminDBManager();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.course['name']} ${widget.course['major']}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Divider(
            thickness: 1,
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: FutureBuilder(
              future: adminDBManager.getSections(courseId: widget.course['id'] as int), 
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }
                else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
            
                final sectionList = snapshot.data as List<Map<String, dynamic>>;
                final sectionItems = sectionList.map((section) {
                  return Container(
                    width: double.infinity,
                    child: Card(
                      child: ListTile(
                        mouseCursor: SystemMouseCursors.click,
                        minVerticalPadding: 0,
                        title: Text(
                          '${section['year_level']}${section['year_level'] == 1 ? "st" : section['year_level'] == 2 ? "nd" : section['year_level'] == 3 ? "rd" : "th"} Year', 
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        subtitle: Text(
                          '${widget.course['name']} ${widget.course['major']}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        iconColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          showDialog(
                            context: context, 
                            builder: (context) {
                              return FutureBuilder(
                                future: adminDBManager.getCurriculum(
                                  courseId: section['course']['id'] as int,
                                  yearLevel: section['year_level'] as int,
                                ), 
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return AlertDialog(
                                      title: Text('Error'),
                                      content: Text(snapshot.error.toString()),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  }
                                  final curriculumList = snapshot.data as List<dynamic>? ?? [];
                                  if (curriculumList.isEmpty) {
                                    return AlertDialog(
                                      title: Text('Choose a semester:'),
                                      content: Text('No curriculum available for this selection.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  }
                                  final curriculumBySem = groupBy(curriculumList, (s) => s['semester_no']);
                                  final semesterButtons = curriculumBySem.keys.map((semester) {
                                    return TextButton(
                                      onPressed: () {
                                        logger.d('Semester: $semester');
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(builder: (context) => BaseLayout(body: ScheduleManagerGate(section: section, semNo: semester as int,)))
                                        );
                                      },
                                      child: Text("Semester ${semester}"),
                                    );
                                  }).toList();
                                  return AlertDialog(
                                    title: Text('Choose a semester:', style: Theme.of(context).textTheme.bodyMedium),
                                    actions: semesterButtons,
                                  );
                                }
                              );
                            }
                          );
                        },
                      ),
                    ),
                  );
                }).toList();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListView.builder(
                    itemCount: sectionList.length,
                    itemBuilder: (context, index) {
                      return sectionItems[index];
                    }
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}