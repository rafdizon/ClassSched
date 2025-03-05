import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';

class HistoryDatesTab extends StatefulWidget {
  const HistoryDatesTab({super.key});

  @override
  State<HistoryDatesTab> createState() => _HistoryDatesTabState();
}

class _HistoryDatesTabState extends State<HistoryDatesTab> {
  final adminDBManager = AdminDBManager();
  
  Stream<List<Map<String, dynamic>>>? streamSem;

  void initStreamSem() async {
    final acadYearMap = await adminDBManager.fetchAcadYearData();

    setState(() {
      streamSem = adminDBManager.database.from('semester').stream(primaryKey: ['id']).order('start_date').limit(3)
        .map((sems) => sems.map((sem) {
          final acadYear = acadYearMap[sem['academic_year_id']];
          return {
            'id' : sem['id'],
            'number' : sem['number'],
            'academic_year' : acadYear['academic_year'],
            'start_date' : sem['start_date'],
            'end_date' : sem['end_date'],
            'is_active' : acadYear['is_active']
          };
        }).toList()
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}