import 'package:class_sched/admin_side/base_layout.dart';
import 'package:class_sched/admin_side/schedule_manager/schedules_by_course_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

final logger = Logger();
class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> with SingleTickerProviderStateMixin {
  final adminDBManager = AdminDBManager();
  var _selectedNavigIndex = 0;
  late Future<List<dynamic>> _courseFuture;

  bool _isSideMenuOpen = false;
  late AnimationController _menuController;
  late Animation<Offset> _menuSlideAnimation;

  void toggleMenu() {
    setState(() {
      _isSideMenuOpen = !_isSideMenuOpen;
      _isSideMenuOpen ? _menuController.forward() : _menuController.reverse();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _courseFuture = adminDBManager.getCourses();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(_menuController);
  }
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double navRailWidth = (constraints.maxWidth * 0.177).clamp(200, 250);
          double bodyWidth = constraints.maxWidth - (constraints.maxWidth * 0.1777);
          return FutureBuilder(
            future: _courseFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
          
              final courses = snapshot.data as List<Map<String, dynamic>>;
              final courseRails = courses.map((course) {
                return NavigationRailDestination(
                  icon: const Icon(Icons.access_time, color: Colors.white,),
                  selectedIcon: const Icon(Icons.access_time),
                  label: Text(course['short_form'].toString(), style: const TextStyle(color: Colors.white),)
                );
              }).toList();

              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Container(
                      width: navRailWidth,
                      height: constraints.maxHeight,
                      color: Theme.of(context).colorScheme.primary,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Schedule Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          Divider(
                            color: Theme.of(context).colorScheme.secondary,
                            indent: 20,
                            endIndent: 20,
                          ),
                          Expanded(
                            child: NavigationRail(
                              extended: true,
                              backgroundColor: Colors.transparent,
                              indicatorColor: Theme.of(context).colorScheme.secondary,
                              destinations: courseRails, 
                              selectedIndex: _selectedNavigIndex,
                              onDestinationSelected: (value) {
                                setState(() {
                                  _selectedNavigIndex = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: bodyWidth,
                      child: SchedulesByCoursePage(course: courses[_selectedNavigIndex],),
                    ),
                  ],
                );
              }
              else {
                return Stack(
                  children: [
                    SchedulesByCoursePage(course: courses[_selectedNavigIndex],),
                    _isSideMenuOpen ? Positioned.fill(
                      child: GestureDetector(
                        onTap: toggleMenu,
                        child: Container(color: Colors.transparent,)
                      )
                    ) : const SizedBox.shrink(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: toggleMenu, 
                        icon: const Icon(Icons.chevron_right),
                      )
                    ),
                    SlideTransition(
                      position: _menuSlideAnimation,
                      child: Container(
                        width: 200,
                        height: constraints.maxHeight,
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Schedule Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            Divider(
                              color: Theme.of(context).colorScheme.secondary,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Expanded(
                              child: NavigationRail(
                                extended: true,
                                backgroundColor: Colors.transparent,
                                indicatorColor: Theme.of(context).colorScheme.secondary,
                                destinations: courseRails, 
                                selectedIndex: _selectedNavigIndex,
                                onDestinationSelected: (value) {
                                  setState(() {
                                    _selectedNavigIndex = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
          );
        }
      )
    );
  }
}