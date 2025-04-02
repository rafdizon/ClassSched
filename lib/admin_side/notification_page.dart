import 'package:class_sched/admin_side/instructor_accounts_page.dart';
import 'package:class_sched/admin_side/student_accounts_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String selectedUserType = "All";
  String selectedStatus = "All";
  String selectedNotificationType = "All";

  final List<String> userTypeOptions = ["All", "Student", "Instructor"];
  final List<String> statusOptions = ["All", "Sent", "Pending", "Resolved"];
  final List<String> notificationTypeOptions = ["All", "Bug", "Schedule", "Account"];

  String formatCreatedAt(String createdAt) {
    DateTime utcDateTime = DateTime.parse(createdAt);
    
    final tzDateTime = tz.TZDateTime.from(utcDateTime, tz.local);

    final formatter = DateFormat('MM-dd-yyyy hh:mm a');
    return formatter.format(tzDateTime);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future _deletNotif(int id) async {
    await AdminDBManager().deleteNotification(id: id);
  }

  bool filterNotification(Map<String, dynamic> notif) {
    bool matchesUserType = true;
    if (selectedUserType != "All") {
      bool isSenderStudent = notif['student'] != null;
      String notifUserType = isSenderStudent ? "Student" : "Instructor";
      matchesUserType = notifUserType == selectedUserType;
    }

    bool matchesStatus = true;
    if (selectedStatus != "All") {
      String notifStatus = notif['status'] ?? 'Unread';
      matchesStatus = notifStatus == selectedStatus;
    }

    bool matchesNotificationType = true;
    if (selectedNotificationType != "All") {
      String header = notif['header'] ?? "";
      matchesNotificationType = header.contains(selectedNotificationType);
    }

    return matchesUserType && matchesStatus && matchesNotificationType;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(70,20,70,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notifications', style: Theme.of(context).textTheme.displayMedium,),
              IconButton(
                onPressed: () {
                  setState(() {});
                }, 
                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary,)
              )
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
          Row(
            spacing: 20,
            children: [
              DropdownButton<String>(
                value: selectedUserType,
                items: userTypeOptions
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedUserType = value;
                    });
                  }
                },
                hint: const Text("User Type"),
              ),
              DropdownButton<String>(
                value: selectedStatus,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
                hint: const Text("Status"),
              ),
              DropdownButton<String>(
                value: selectedNotificationType,
                items: notificationTypeOptions
                    .map((notifType) => DropdownMenuItem(
                          value: notifType,
                          child: Text(notifType),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedNotificationType = value;
                    });
                  }
                },
                hint: const Text("Notification Type"),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: AdminDBManager().getNotifications(), 
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()),);
                }
            
                List<Map<String, dynamic>>? notifList = snapshot.data ?? [];
                List<Map<String, dynamic>> filteredNotifs = notifList!.where(filterNotification).toList();

                if (filteredNotifs.isNotEmpty) {
                  final notifItems = filteredNotifs.map((notif) {
                    bool isSenderStudent = notif['student'] != null;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          Logger().i(notif['id']);
                          await AdminDBManager().markNotifRead(id: notif['id'] as int);
                          showDialog(
                            context: context, 
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  width: 500,
                                  height: 330,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(notif['header'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),),
                                        Text(
                                          'Sent by: ${isSenderStudent ? notif['student']['first_name'] : notif['instructor']['first_name']} ${isSenderStudent ? notif['student']['last_name'] : notif['instructor']['last_name']}', 
                                          style: Theme.of(context).textTheme.bodySmall
                                        ),
                                        Text(isSenderStudent ? notif['student']['email'] : notif['instructor']['email'], style: Theme.of(context).textTheme.bodySmall),
                                        Text(isSenderStudent ? notif['student']['student_no'] : '', style: Theme.of(context).textTheme.bodySmall),
                                        Divider(color: Theme.of(context).colorScheme.primary,),
                                        SizedBox(
                                          height: 150,
                                          child: TextField(
                                            readOnly: true,
                                            controller: TextEditingController(text: notif['body']),
                                            style: Theme.of(context).textTheme.bodySmall,
                                            expands: true,
                                            minLines: null,
                                            maxLines: null,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              onPressed: (){
                                                Navigator.push(
                                                  context, 
                                                  MaterialPageRoute(
                                                    builder: (context) { 
                                                      if (isSenderStudent){
                                                        return StudentAccountsPage(
                                                        studentId: notif['student']['student_no'],
                                                      );
                                                      }
                                                      return InstructorAccountsPage(
                                                        instEmail: notif['instructor']['email'],
                                                      );
                                                    }
                                                  )
                                                );
                                              },
                                              child: Text('View Sender', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await _deletNotif(notif['id']);
                                                setState(() {});
                                              }, 
                                              child: Text(
                                                'Delete',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await AdminDBManager().markNotifResolved(id: notif['id'] as int);
                                                Navigator.pop(context);
                                              }, 
                                              child: Text(
                                                'Mark as Resolved',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          );
                          setState(() {});
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Table(
                              columnWidths: const {
                                0 : FractionColumnWidth(0.1),
                                1 : FractionColumnWidth(0.1),
                                2 : FractionColumnWidth(0.25),
                                3 : FractionColumnWidth(0.15),
                                4 : FractionColumnWidth(0.2), 
                                5 : FractionColumnWidth(0.2)
                              },
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text(
                                        notif['status'] ?? 'Unread',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                        ),
                                      )
                                    ),
                                    TableCell(
                                      child: Text(
                                        isSenderStudent ? 'Student' : 'Instructor',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                        ),
                                      )
                                    ),
                                    TableCell(
                                      child: Text(
                                        isSenderStudent ? notif['student']['email'] : notif['instructor']['email'], 
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                        ),
                                      )
                                    ),
                                    TableCell(
                                      child: Text(
                                        notif['header'], 
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Text(
                                          notif['body'], 
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        formatCreatedAt(notif['created_at']),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    )
                                  ]
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList();
                  return ListView.builder(
                    itemCount: notifItems.length,
                    itemBuilder: (context, index) {
                      return notifItems[index];
                    }
                  );
                }
                else {
                  return const Text('No notifications yet');
                }
                
              }
            ),
          ),
        ],
      ),
    );
  }
}