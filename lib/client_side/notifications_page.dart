import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  String _formatWithBreakDate(String rawDate) {
    final dt = DateTime.parse(rawDate);
    final localDt = dt.toLocal();
    return DateFormat("MM/dd/yy\nhh:mma").format(localDt).toLowerCase();
  }
  String _formatDate(String rawDate) {
    final dt = DateTime.parse(rawDate);
    final localDt = dt.toLocal();
    return DateFormat("MM/dd/yy hh:mma").format(localDt).toLowerCase();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10,),
      child: Column(
        children: [
          Text(
            'Notifications', 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.primary,),
          Expanded(
            child: FutureBuilder(
              future: ClientDBManager().getNotifs(), 
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }
                List<Map<String, dynamic>>? notifData = snapshot.data;
                
                if(notifData != null) {
                  final notifItems = notifData.map((notif) {
                  return Card(
                    child: ListTile(
                      onTap: () => showDialog(
                        context: context, 
                        builder: (context) => AlertDialog(
                          title: Text('Report', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notif['report']['header'], style: Theme.of(context).textTheme.bodyMedium,),
                              Text(notif['report']['body'], style: Theme.of(context).textTheme.bodySmall,),
                              const SizedBox(height: 30,),
                              Text(notif['report']['status'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),),
                            ],
                          ),
                        )
                      ),
                      leading: Icon(
                        notif['report']['status'] == 'Pending' ? Icons.remove_red_eye_outlined
                        : Icons.check_box,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title:  Text(
                        notif['report']['status'] == 'Pending' ? 'The admin is working on your ${notif['report']['header']} issue'
                        : 'The admin has resolved your ${notif['report']['header']} issue!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        'Reported on: ${_formatDate(notif['report']['created_at'])}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      trailing: Text(
                        _formatWithBreakDate(notif['created_at'].toString()),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black45
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
                  return  Text('No notifications yet', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black45
                  ));
                }
                
              }
            ),
          ),
        ],
      ),
    );
  }
}