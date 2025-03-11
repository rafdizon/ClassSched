import 'package:flutter/material.dart';

class ViewScheduleBySectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> schedule;
  const ViewScheduleBySectionPage({super.key, required this.schedule});

  @override
  State<ViewScheduleBySectionPage> createState() => _ViewScheduleBySectionPageState();
}

class _ViewScheduleBySectionPageState extends State<ViewScheduleBySectionPage> {
  @override
  Widget build(BuildContext context) {
    final scheduleRows = widget.schedule.map((sched) {
      return DataRow(
        cells: [
          DataCell(
            Text(sched['curriculum']['subject']['code'], style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text(sched['curriculum']['subject']['name'], style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text(sched['cycle']['cycle_no'], style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text('${sched['cycle']['start_date']} to ${sched['cycle']['end_date']}', style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text(sched['start_time'], style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text(sched['end_time'], style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text('${sched['instructor']['first_name']} ${sched['instructor']['last_name']}', style: Theme.of(context).textTheme.bodySmall,)
          ),
          DataCell(
            Text(sched['curriculum']['subject']['units'].toString(), style: Theme.of(context).textTheme.bodySmall,)
          ),
        ]
      );
    }).toList();
    return DataTable(
      headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
      columns: [
        DataColumn(label: Text('Code', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('Subject', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('Cycle', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('Date', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('Start Time', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('End Time', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('Instructor', style: Theme.of(context).textTheme.bodySmall,)),
        DataColumn(label: Text('Units', style: Theme.of(context).textTheme.bodySmall,)),
      ], 
      rows: scheduleRows
    );
  }
}