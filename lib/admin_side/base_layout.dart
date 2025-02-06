import 'package:class_sched/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:class_sched/services/auth_service.dart';

class BaseLayout extends StatefulWidget {
  final Widget body;
  const BaseLayout({
    super.key,
    required this.body
  });

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  final authService = AuthService();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(preferredSize: Size.fromHeight(1), child: Container(color: Colors.black, height: 0.25,)),
        foregroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              }, 
              icon: const Icon(Icons.menu)
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
            const Image(
              image: AssetImage('assets/images/logo3.png'),
              width: 150,
              fit: BoxFit.fitWidth,
            ),
            IconButton(
              onPressed: () {} , 
              icon: const Icon(Icons.person_outline)
            )
          ],
        ),
        //title: Image(image: image),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: NavigationRail(
                backgroundColor: Theme.of(context).colorScheme.primary,
                extended: true,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.person_2_outlined, color: Colors.white,), 
                    selectedIcon: Icon(Icons.person_2),
                    label: Text('Accounts', style: TextStyle(color: Colors.white),)
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.data_thresholding_outlined, color: Colors.white,),
                    selectedIcon: Icon(Icons.data_thresholding_rounded),
                    label: Text('Dashboard', style: TextStyle(color: Colors.white),)
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings, color: Colors.white,),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('School Setup', style: TextStyle(color: Colors.white),)
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notifications_active_outlined, color: Colors.white,),
                    selectedIcon: Icon(Icons.notifications_active_rounded),
                    label: Text('Notifications', style: TextStyle(color: Colors.white),)
                  ),
                  
                ], 
                selectedIndex: 1
              ),
            ),
            GestureDetector(
              onTap: logout,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.primary,
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white,),
                    SizedBox(width: 10,),
                    Text('Logout', style: TextStyle(color: Colors.white))
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