import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:logger/logger.dart';

final logger = Logger();
class ViewScheduleBySectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> schedule;
  const ViewScheduleBySectionPage({super.key, required this.schedule});

  @override
  State<ViewScheduleBySectionPage> createState() => _ViewScheduleBySectionPageState();
}

class _ViewScheduleBySectionPageState extends State<ViewScheduleBySectionPage> {
  @override
  Widget build(BuildContext context) {
    final scheduleMapGrouped = groupBy(widget.schedule, (sched) => sched['cycle']['semester']['number']);
    logger.d(scheduleMapGrouped);

    List<Widget> semesterTables = scheduleMapGrouped.entries.map((entry) {
      final semNumber = entry.key;
      final semSched = entry.value;

      final scheduleRows = semSched.map((sched) {
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
      return Column(
        children: [
          Text('Semester $semNumber'),
          SingleChildScrollView(
            child: SizedBox(
              height: 500,
              child: DataTable2(
                headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                dataRowHeight: 80,
                columns: [
                  DataColumn2(label: Text('Code', style: Theme.of(context).textTheme.bodySmall,), fixedWidth: 80),
                  DataColumn2(label: Text('Subject', style: Theme.of(context).textTheme.bodySmall,), size: ColumnSize.L),
                  DataColumn2(label: Text('Cycle', style: Theme.of(context).textTheme.bodySmall,), fixedWidth: 100),
                  DataColumn2(label: Text('Date', style: Theme.of(context).textTheme.bodySmall,), size: ColumnSize.L),
                  DataColumn2(label: Text('Start Time', style: Theme.of(context).textTheme.bodySmall,), size: ColumnSize.S),
                  DataColumn2(label: Text('End Time', style: Theme.of(context).textTheme.bodySmall,), size: ColumnSize.S),
                  DataColumn2(label: Text('Instructor', style: Theme.of(context).textTheme.bodySmall,), size: ColumnSize.S),
                  DataColumn2(label: Text('Units', style: Theme.of(context).textTheme.bodySmall,), fixedWidth: 80),
                ], 
                rows: scheduleRows
              ),
            ),
          )
        ],
      );
    }).toList();
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.schedule[0]['curriculum']['course']['short_form']} - ${widget.schedule[0]['section']['year_level']}', style: Theme.of(context).textTheme.bodyLarge,),
            ...semesterTables
          ],
        ),
      ),
    );
  }
}