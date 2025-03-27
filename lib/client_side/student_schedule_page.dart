import 'package:class_sched/client_side/student_schedule_tabs/schedule_calendar_tab.dart';
import 'package:class_sched/client_side/student_schedule_tabs/schedule_table_tab.dart';
import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class StudentSchedulePage extends StatefulWidget {
  const StudentSchedulePage({super.key});

  @override
  State<StudentSchedulePage> createState() => _StudentSchedulePageState();
}

class _StudentSchedulePageState extends State<StudentSchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Calendar',),
              Tab(text: 'Table',)
            ]
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ScheduleCalendarTab(),
              ScheduleTableTab(),
            ]
          ),
        )
      ],
    );
  }
}
