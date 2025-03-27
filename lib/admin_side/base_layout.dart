import 'package:class_sched/admin_side/dashboard_page.dart';
import 'package:class_sched/admin_side/notification_page.dart';
import 'package:class_sched/auth_gate.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:class_sched/services/auth_service.dart';
import 'package:badges/badges.dart' as badges;

class BaseLayout extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  const BaseLayout({
    super.key,
    required this.body,
    this.selectedIndex = 0
  });

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  final authService = AuthService();
  late int _generalSelectedNavigIndex;

  void logout() async {
    try {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    }
    catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $e')));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _generalSelectedNavigIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Theme.of(context).colorScheme.primary, height: 0.5,)),
        foregroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Navigator.canPop(context) ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    }, 
                    icon: const Icon(Icons.menu)
                  ),
                ],
              ),
            );
          }
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Image(
              image: AssetImage('assets/images/logo1.png'),
              width: 120,
              fit: BoxFit.fitWidth,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => BaseLayout(body: DashboardPage()))
                  );
                },
                child: const Image(
                  image: AssetImage('assets/images/logo3.png'),
                  width: 150,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Admin'),
                      content: Text('classschedspusm@edu.ph'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Back', 
                            style: 
                            TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            logout();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                );
              } , 
              icon: const Icon(Icons.person_outline)
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: NavigationRail(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                extended: true,
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.data_thresholding_outlined),
                    selectedIcon: Icon(Icons.data_thresholding_rounded),
                    label: Text('Dashboard')
                  ),
                  NavigationRailDestination(
                    icon: FutureBuilder(
                      future: AdminDBManager().database.from('report').count().eq('is_opened', false), 
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return badges.Badge(
                            badgeContent: Text(
                              '0',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white
                              ),
                            ),
                            child: Icon(Icons.notifications_active_outlined),
                            position: badges.BadgePosition.topEnd(end: -5, top: -5),
                            showBadge: true,
                          );
                        }
                        final notifCount = snapshot.data as int;
                        return badges.Badge(
                          badgeContent: Text(
                            notifCount.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white
                            ),
                          ),
                          child: Icon(Icons.notifications_active_outlined),
                          position: badges.BadgePosition.topEnd(end: -5, top: -5),
                          showBadge: true,
                        );
                      }
                    ),
                    selectedIcon: Icon(Icons.notifications_active_rounded),
                    label: Text('Notifications')
                  ),
                ], 
                selectedIndex: _generalSelectedNavigIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _generalSelectedNavigIndex = index;
                  });

                  Widget nextPage;
                  switch (index) {
                    case 0:
                      nextPage = const DashboardPage(); 
                      break;
                    case 1:
                      nextPage = const NotificationPage(); 
                      break;
                    default:
                      nextPage = widget.body; 
                  }

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => BaseLayout(body: nextPage, selectedIndex: index,)),
                  );
                }
              ),
            ),
            GestureDetector(
              onTap: logout,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.tertiary,
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10,),
                    Text('Logout')
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      body: widget.body,
    );
  }
}