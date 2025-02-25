import 'package:flutter/material.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:logger/logger.dart';

var logger = Logger();
class BySemTabs extends StatefulWidget {
  final int semId;
  final int semNo;

  const BySemTabs({super.key, required this.semId, required this.semNo});

  @override
  State<BySemTabs> createState() => _BySemTabsState();
}

class _BySemTabsState extends State<BySemTabs> {
  final adminDBManager = AdminDBManager();

  var _selectedRows = [];

  Stream<List<Map<String, dynamic>>>? streamCycles;

  @override
  void initState() {
    // TODO: implement initState
    streamCycles = adminDBManager.database.from('cycle').stream(primaryKey: ['id']).eq('semester_id', widget.semId)
      .map((cycles) => cycles.map((cycle) {
        return {
          'id' : cycle['id'],
          'cycle_no' : cycle['cycle_no'],
          'start_date' : cycle['start_date'],
          'end_date' : cycle['end_date'],
        };
      }).toList()
      );
  }
  @override
  Widget build(BuildContext context) {
    logger.d(widget.semId);
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: streamCycles, 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else if(snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final cyclesList = snapshot.data as List<Map<String, dynamic>>;
          //logger.d(cyclesList);
          final cyclesRows = cyclesList.map((cycles) {
            return DataRow(
              cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 20),
                    child: Checkbox(
                      value: _selectedRows.contains(cycles['id']),
                      onChanged: (value) {
                        setState(() {
                          if(value == true) {
                            _selectedRows.add(cycles['id']);
                          } else {
                            _selectedRows.remove(cycles['id']);
                          }
                          //logger.d(_selectedRows);
                        });
                      },
                    ),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 20),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context, 
                          barrierDismissible: false,
                          builder: (context) => const Placeholder()
                        );
                      }, 
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary,)
                    ),
                  ),
                ),
                DataCell(Text(cycles['cycle_no'], style: Theme.of(context).textTheme.bodySmall,)),
                DataCell(Text(cycles['start_date'], style: Theme.of(context).textTheme.bodySmall,)),
                DataCell(Text(cycles['end_date'], style: Theme.of(context).textTheme.bodySmall,)),
              ]
            );
          }).toList();
          return DataTable(
            headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
            columns: const [
              DataColumn(label: Text('')),
              DataColumn(label: Text('')),
              DataColumn(label: Text('Cycle')),
              DataColumn(label: Text('Start Date')),
              DataColumn(label: Text('End Date')),
            ], 
            rows: cyclesRows
          );
        }
      ),
    );
    
  }
}