import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();
class HistoryDatesTab extends StatefulWidget {
  const HistoryDatesTab({super.key});

  @override
  State<HistoryDatesTab> createState() => _HistoryDatesTabState();
}

class _HistoryDatesTabState extends State<HistoryDatesTab> {
  final adminDBManager = AdminDBManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: adminDBManager.fetchAcadYearData(), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        }
        else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()),);
        }

        final acadYearMap = snapshot.data as Map<int, dynamic>;
        final acadYearList = acadYearMap.values.toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 80),
            itemCount: acadYearList.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(acadYearList[index]['academic_year'], style: Theme.of(context).textTheme.bodyMedium,),
                  subtitle: Text('Academic Year', style: Theme.of(context).textTheme.bodySmall,),
                  leading: const Icon(Icons.calendar_today_rounded),
                  trailing: IconButton(
                    onPressed: (){}, 
                    icon: const Icon(Icons.arrow_forward_ios_rounded)
                  ),
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          ),
        );
      } 
    );
  }
}