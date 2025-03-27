import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/schedule_manager/edit_schedule.dart';
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
  final ScrollController _scrollHorizontal = ScrollController();
  final ScrollController _scrollVertical = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollHorizontal.dispose();
    _scrollVertical.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final filteredSchedule = widget.schedule.where((sched) => sched['cycle']['semester']['number'] == widget.semNo).toList();

    if (filteredSchedule.isEmpty) {
      return Center(child: Text("No schedule available for semester ${widget.semNo}"));
    }

    final scheduleRows = filteredSchedule.map((sched) {
      return DataRow(
        cells: [
          DataCell(Text(sched['curriculum']['subject']['code'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['curriculum']['subject']['name'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['cycle']['cycle_no'], style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text('${sched['cycle']['start_date']} to ${sched['cycle']['end_date']}', style: Theme.of(context).textTheme.bodySmall)),
          DataCell(Text(sched['days'].join(', '), style: Theme.of(context).textTheme.bodySmall)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Semester ${widget.semNo}', style: Theme.of(context).textTheme.bodyMedium,),
                TextButton(
                  onPressed: (){
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) {
                          logger.d(widget.schedule[0]['section'].toString());
                          return BaseLayout(body: EditSchedule(schedule: widget.schedule, semNo: widget.semNo,));
                        } 
                      )
                    );
                  }, 
                  child: Text('Edit Schedule', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),)
                )
              ],
            ),
            SizedBox(
              height: 500,
              child: Scrollbar(
                controller: _scrollHorizontal,
                interactive: true,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollHorizontal,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
                    dataRowMinHeight: 70,
                    dataRowMaxHeight: 80,
                    columns: [
                      DataColumn(label: Text('Code', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('Subject', style: Theme.of(context).textTheme.bodySmall),),
                      DataColumn(label: Text('Cycle', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('Date', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('Days', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('Start Time', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('End Time', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('Instructor', style: Theme.of(context).textTheme.bodySmall), ),
                      DataColumn(label: Text('Units', style: Theme.of(context).textTheme.bodySmall), ),
                    ],
                    rows: scheduleRows,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}