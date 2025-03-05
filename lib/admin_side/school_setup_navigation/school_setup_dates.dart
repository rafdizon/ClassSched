import 'package:class_sched/admin_side/school_setup_navigation/dates_tabs/current_dates_tab.dart';
import 'package:class_sched/admin_side/school_setup_navigation/dates_tabs/history_dates_tab.dart';
import 'package:flutter/material.dart';

class SchoolSetupDates extends StatefulWidget {
  const SchoolSetupDates({super.key});

  @override
  State<SchoolSetupDates> createState() => _SchoolSetupDatesState();
}

class _SchoolSetupDatesState extends State<SchoolSetupDates> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);

    _mainTabController.addListener((){
      if (_mainTabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dates', style: Theme.of(context).textTheme.displayMedium,),
              SizedBox(
                width: 200,
                height: 50,
                child: TabBar(
                  controller: _mainTabController,
                  tabs: const [
                    Tab(text: "Ongoing",),
                    Tab(text: "History",),
                  ]
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 150, // Adjust as needed
            child: TabBarView(
              controller: _mainTabController,
              children: const [
                CurrentDatesTab(),
                HistoryDatesTab(),
              ],
            ),
          ),
        ]
      ),
    );
  }
}