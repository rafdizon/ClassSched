import 'package:class_sched/ui_elements/current_dates_tab.dart';
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
        setState(() {
          
        });
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
    return Column(
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
        Expanded(
          child: TabBarView(
            controller: _mainTabController,
            children: const [
              CurrentDatesTab(),
              Text("History"),
            ],
          ),
        )
      ]
    );
  }
}