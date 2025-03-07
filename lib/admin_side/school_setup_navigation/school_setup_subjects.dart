import 'package:class_sched/admin_side/school_setup_navigation/subjects_tabs/curriculum_tab.dart';
import 'package:class_sched/admin_side/school_setup_navigation/subjects_tabs/subjects_tab.dart';
import 'package:flutter/material.dart';

class SchoolSetupSubjects extends StatefulWidget {
  const SchoolSetupSubjects({super.key});

  @override
  State<SchoolSetupSubjects> createState() => _SchoolSetupSubjectsState();
}

class _SchoolSetupSubjectsState extends State<SchoolSetupSubjects> with SingleTickerProviderStateMixin{
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Curriculum', style: Theme.of(context).textTheme.displayMedium,),
              SizedBox(
                width: 300,
                height: 50,
                child: TabBar(
                  controller: _mainTabController,
                  tabs: const [
                    Tab(text: 'Curriculum',),
                    Tab(text: 'General Subjects',),
                  ]
                ),
              )
            ],
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: const [
                CurriculumTab(),
                SubjectsTab(),
              ]
            ),
          )
        ],
      ),
    );
  }
}