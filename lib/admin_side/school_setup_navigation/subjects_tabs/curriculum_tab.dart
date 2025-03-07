import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurriculumTab extends StatefulWidget {
  const CurriculumTab({super.key});

  @override
  State<CurriculumTab> createState() => _CurriculumTabState();
}

class _CurriculumTabState extends State<CurriculumTab> {
  final adminDBManager = AdminDBManager();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: adminDBManager.getCourses(), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        final courseList = snapshot.data as List<Map<String, dynamic>>;
        final courseItems = courseList.map((courseItem) {
          return Card(
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              minVerticalPadding: 0,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(courseItem['name'], style: Theme.of(context).textTheme.bodySmall,),
                  Text(courseItem['major'].isNotEmpty ? courseItem['major'] : '', style: Theme.of(context).textTheme.bodySmall,)
                ],
              ),
              leading: const Icon(Icons.bookmark),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              iconColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: GridView.builder(
            itemCount: courseItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 80), 
            itemBuilder: (context, index) {
              return courseItems[index];
            }
          ),
        );
      }
    );
  }
}