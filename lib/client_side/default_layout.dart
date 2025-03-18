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
    StudentSchedulePage()
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
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Theme.of(context).colorScheme.primary, height: 0.5,)),
        title: GestureDetector(
          onTap: () {},
          child: const Image(
            image: AssetImage('assets/images/logo3.png'),
            width: 100,
            fit: BoxFit.fitWidth,
          ),
        ),
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
            icon: Icon(_selectedTab == 1 ? Icons.calendar_month : Icons.calendar_month_outlined)
          )
        ]
      ),
    );
  }
}