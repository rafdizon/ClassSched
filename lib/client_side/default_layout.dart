import 'package:class_sched/client_side/client_settings_page.dart';
import 'package:class_sched/client_side/instructor_profile_page.dart';
import 'package:class_sched/client_side/instructor_schedule_page.dart';
import 'package:class_sched/client_side/student_profile_page.dart';
import 'package:class_sched/client_side/student_schedule_page.dart';
import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';

class DefaultLayout extends StatefulWidget {
  const DefaultLayout({super.key});

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  int _selectedTab = 0;
  final List<String> _categories = ["Schedule", "Account", "Bug"];
  final _messageController = TextEditingController();
  late String _selectedCategory;

  final List<Widget> _pages = const [
    StudentProfilePage(),
    StudentSchedulePage(),
  ];

  final List<Widget> _instructorPages = const [
    InstructorProfilePage(),
    InstructorSchedulePage(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCategory = "Schedule";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Theme.of(context).colorScheme.primary, height: 0.5,)),
        title: GestureDetector(
          onTap: () {},
          child: const Image(
            image: AssetImage('assets/images/logo4.png'),
            width: 100,
            fit: BoxFit.fitWidth,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.settings, color: Colors.white,),
            onPressed: (){
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.report_problem_outlined, color: Colors.white,),
              onPressed: () async {
                showDialog(
                  context: context, 
                  builder: (context)  {
                    String selectedCategory = _selectedCategory;
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return AlertDialog(
                          title: Text('Report a problem', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Category: ', style: Theme.of(context).textTheme.bodySmall,),
                              DropdownButton<String>(
                                value: selectedCategory,
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setStateDialog(() {
                                      selectedCategory = newValue;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 20,),
                              Text('Message: ', style: Theme.of(context).textTheme.bodySmall,),
                              const SizedBox(height: 10,),
                              SizedBox(
                                height: 120,
                                child: TextField(
                                  controller: _messageController,
                                  expands: true,
                                  minLines: null,
                                  maxLines: null,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  _selectedCategory = selectedCategory;
                                });
                                await ClientDBManager().sendReport(body: _messageController.text, header: selectedCategory);
                                _messageController.text = "";
                                Navigator.pop(context, "Report has been submitted");
                              },
                              child: Text(
                                'Send', 
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold, 
                                  color: Theme.of(context).colorScheme.primary
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
                ).then((result) {
                  if(result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result), backgroundColor: Theme.of(context).colorScheme.primary,)
                    );
                  }
                });
              },
            ),
          )
        ],
      ),
      drawer: const ClientSettingsPage(),
      body: FutureBuilder<bool>(
        future: ClientDBManager().isUserStudent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          }
          final bool isStudent = snapshot.data ?? true;
          return IndexedStack(
            index: _selectedTab,
            children: isStudent ? _pages : _instructorPages,
          );
        },
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
        ]
      ),
    );
  }
}