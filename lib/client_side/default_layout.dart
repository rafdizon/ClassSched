import 'package:class_sched/client_side/student_notification_page.dart';
import 'package:class_sched/client_side/student_profile_page.dart';
import 'package:class_sched/client_side/student_schedule_page.dart';
import 'package:flutter/material.dart';

class DefaultLayout extends StatefulWidget {
  const DefaultLayout({super.key});

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  int _selectedTab = 0;

  final List<Widget> _pages = const [
    StudentProfilePage(),
    StudentSchedulePage(),
    StudentNotificationPage()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(150),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Theme.of(context).colorScheme.primary, height: 0.5,)),
        title: GestureDetector(
          onTap: () {},
          child: const Image(
            image: AssetImage('assets/images/logo3.png'),
            width: 100,
            fit: BoxFit.fitWidth,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white,),
          onPressed: (){},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.report_problem_outlined, color: Colors.white,),
              onPressed: (){},
            ),
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_selectedTab == 0 ? Icons.person_4 : Icons.person_4_outlined),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedTab == 1 ? Icons.calendar_month : Icons.calendar_month_outlined),
            label: 'Schedules'
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedTab == 2 ? Icons.notifications_rounded : Icons.notifications_none),
            label: 'Notifications'
          ),
        ]
      ),
    );
  }
}