import 'package:class_sched/admin_side/school_setup_navigation/dates_tabs/edit_cycle_dialog.dart';
import 'package:class_sched/ui_elements/add_cycle_dialog.dart';
import 'package:flutter/material.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:logger/logger.dart';
import 'package:data_table_2/data_table_2.dart';

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

  Stream<List<Map<String, dynamic>>>? streamCycles;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamCycles = adminDBManager.database.from('cycle').stream(primaryKey: ['id']).eq('semester_id', widget.semId).order('cycle_no', ascending: true)
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
          final cyclesRows = cyclesList.map((cycles) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final error = await adminDBManager.deleteCycle(id: cycles['id']);

                          if(error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully!'), backgroundColor: Theme.of(context).colorScheme.primary,));
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                          }
                          setState(() {
                            streamCycles = adminDBManager.database
                              .from('cycle')
                              .stream(primaryKey: ['id'])
                              .eq('semester_id', widget.semId)
                              .order('cycle_no', ascending: true)
                              .map((cycles) => cycles
                                  .map((cycle) => {
                                        'id': cycle['id'],
                                        'cycle_no': cycle['cycle_no'],
                                        'start_date': cycle['start_date'],
                                        'end_date': cycle['end_date'],
                                      })
                                  .toList());
                          });
                        }, 
                        icon: const Icon(Icons.delete, color: Colors.red,)
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await showDialog(
                            context: context, 
                            barrierDismissible: false,
                            builder: (context) => EditCycleDialog(cycleData: cycles, semId: widget.semId)
                          );
                          if (result == true) {
                            setState(() {
                              streamCycles = adminDBManager.database
                                .from('cycle')
                                .stream(primaryKey: ['id'])
                                .eq('semester_id', widget.semId)
                                .order('cycle_no', ascending: true)
                                .map((cycles) => cycles.map((cycle) {
                                      return {
                                        'id': cycle['id'],
                                        'cycle_no': cycle['cycle_no'],
                                        'start_date': cycle['start_date'],
                                        'end_date': cycle['end_date'],
                                      };
                                    }).toList());
                            });
                          }
                        }, 
                        icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary,)
                      ),
                    ],
                  ),
                ),
                DataCell(Text(cycles['cycle_no'], style: Theme.of(context).textTheme.bodySmall,)),
                DataCell(Text(cycles['start_date'], style: Theme.of(context).textTheme.bodySmall,)),
                DataCell(Text(cycles['end_date'], style: Theme.of(context).textTheme.bodySmall,)),
              ]
            );
          }).toList();
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: DataTable2(
              headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
              columns: const [
                DataColumn2(label: Text(''), fixedWidth: 200),
                DataColumn2(label: Text('Cycle')),
                DataColumn2(label: Text('Start Date')),
                DataColumn2(label: Text('End Date')),
              ], 
              rows: [
                ...cyclesRows,
                DataRow(
                  cells: [
                    DataCell(
                      Center(
                        child: IconButton(
                          onPressed: () async {
                            final result = await showDialog(
                              context: context, 
                              builder: (context) => AddCycleDialog(cycleNo: cyclesList.isNotEmpty ? int.tryParse(cyclesList.last['cycle_no']) ?? 0 : 0, semId: widget.semId)
                            );
                            if (result == true) {
                              setState(() {
                                streamCycles = adminDBManager.database.from('cycle').stream(primaryKey: ['id']).eq('semester_id', widget.semId).order('cycle_no', ascending: true)
                                  .map((cycles) => cycles.map((cycle) {
                                    return {
                                      'id' : cycle['id'],
                                      'cycle_no' : cycle['cycle_no'],
                                      'start_date' : cycle['start_date'],
                                      'end_date' : cycle['end_date'],
                                    };
                                  }).toList()
                                );
                              });
                            }
                          }, 
                          icon: const Icon(Icons.add), 
                        ),
                      ),
                    ),
                    DataCell(Text('Press + to add a cycle', style: Theme.of(context).textTheme.bodySmall,)),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                  ]
                )
              ]
            ),
          );
        }
      ),
    );
    
  }
}