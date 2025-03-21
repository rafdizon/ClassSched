import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:logger/logger.dart';

final logger = Logger();
class ViewScheduleBySectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> schedule;
  final int semNo;
  const ViewScheduleBySectionPage({super.key, required this.schedule, required this.semNo});

  @override
  State<ViewScheduleBySectionPage> createState() => _ViewScheduleBySectionPageState();
}

class _ViewScheduleBySectionPageState extends State<ViewScheduleBySectionPage> {
  @override
  Widget build(BuildContext context) {
    // Filter the schedule list for the specific semester.
    final filteredSchedule = widget.schedule.where((sched) => sched['cycle']['semester']['number'] == widget.semNo).toList();

    if (filteredSchedule.isEmpty) {
      return Center(child: Text("No schedule available for semester ${widget.semNo}"));
    }

    // Create DataRow for each schedule entry.
    final scheduleRows = filteredSchedule.map((sched) {
      return DataRow(
        cells: [
          DataCell(Text(sched['curriculum']['subject']['code'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['curriculum']['subject']['name'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['cycle']['cycle_no'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${sched['cycle']['start_date']} to ${sched['cycle']['end_date']}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['start_time'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['end_time'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${sched['instructor']['first_name']} ${sched['instructor']['last_name']}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['curriculum']['subject']['units'].toString(), style: Theme.of(context).textTheme.bodySmall)),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.schedule[0]['curriculum']['course']['short_form']} - ${widget.schedule[0]['section']['year_level']}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text('Semester ${widget.semNo}'),
            SingleChildScrollView(
              child: SizedBox(
                height: 500,
                child: DataTable2(
                  headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                  dataRowHeight: 80,
                  columns: [
                    DataColumn2(label: Text('Code', style: Theme.of(context).textTheme.bodySmall), fixedWidth: 80),
                    DataColumn2(label: Text('Subject', style: Theme.of(context).textTheme.bodySmall), size: ColumnSize.L),
                    DataColumn2(label: Text('Cycle', style: Theme.of(context).textTheme.bodySmall), fixedWidth: 100),
                    DataColumn2(label: Text('Date', style: Theme.of(context).textTheme.bodySmall), size: ColumnSize.L),
                    DataColumn2(label: Text('Start Time', style: Theme.of(context).textTheme.bodySmall), size: ColumnSize.S),
                    DataColumn2(label: Text('End Time', style: Theme.of(context).textTheme.bodySmall), size: ColumnSize.S),
                    DataColumn2(label: Text('Instructor', style: Theme.of(context).textTheme.bodySmall), size: ColumnSize.S),
                    DataColumn2(label: Text('Units', style: Theme.of(context).textTheme.bodySmall), fixedWidth: 80),
                  ],
                  rows: scheduleRows,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}