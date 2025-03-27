import 'package:class_sched/admin_side/student_accounts_page.dart';
import 'package:class_sched/services/admin_db_manager.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(70,20,70,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.displayMedium,),
          Divider(
            color: Theme.of(context).colorScheme.primary,
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
            
                final notifList = snapshot.data as List<Map<String, dynamic>>;
                final notifItems = notifList.map((notif) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
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
                                        'Sent by: ${notif['student']['first_name']} ${notif['student']['last_name']}', 
                                        style: Theme.of(context).textTheme.bodySmall
                                      ),
                                      Text(notif['student']['email'], style: Theme.of(context).textTheme.bodySmall),
                                      Text(notif['student']['student_no'], style: Theme.of(context).textTheme.bodySmall),
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
                                      TextButton(
                                        onPressed: (){
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(builder: (context) => StudentAccountsPage(studentId: notif['student']['student_no'],))
                                          );
                                        },
                                        child: Text('View Sender', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),),
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
                        child: Table(
                          columnWidths: const {
                            0 : FractionColumnWidth(0.1),
                            1 : FractionColumnWidth(0.25),
                            2 : FractionColumnWidth(0.2),
                            3 : FractionColumnWidth(0.25), 
                            4 : FractionColumnWidth(0.2)
                          },
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: SizedBox(width: 20,)
                                ),
                                TableCell(
                                  child: Text(
                                    notif['student']['email'], 
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
                                  child: Text(
                                    notif['body'], 
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: !notif['is_opened'] ? FontWeight.bold : FontWeight.normal
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                  );
                }).toList();
            
                return ListView.builder(
                  itemCount: notifItems.length,
                  itemBuilder: (context, index) {
                    return notifItems[index];
                  }
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}