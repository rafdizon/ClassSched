import 'package:class_sched/admin_side/schedule_manager/add_schedule_to_section_page.dart';
import 'package:class_sched/admin_side/schedule_manager/view_schedule_by_section_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';

final logger = Logger();
class ScheduleManagerGate extends StatefulWidget {
  final Map<String, dynamic> section;
  const ScheduleManagerGate({super.key, required this.section});

  @override
  State<ScheduleManagerGate> createState() => _ScheduleManagerGateState();
}

class _ScheduleManagerGateState extends State<ScheduleManagerGate> {
  final adminDBManager = AdminDBManager();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: adminDBManager.getSchedulesForSection(sectionId: widget.section['id']), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        }
        final result = snapshot.data as List<Map<String, dynamic>>;

        logger.d(result);
        if(result.isNotEmpty) {
          return ViewScheduleBySectionPage(schedule: result);
        }
        else {
          SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No schedule yet, create schedule here'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        });
          return AddScheduleToSection(section: widget.section);
        }
      }
    );
  }
}