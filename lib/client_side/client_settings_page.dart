import 'package:class_sched/services/auth_service.dart';
import 'package:class_sched/services/notifications_student_service.dart';
import 'package:class_sched/ui_elements/change_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:class_sched/services/settings_utils.dart';

class ClientSettingsPage extends StatefulWidget {
  const ClientSettingsPage({super.key});

  @override
  State<ClientSettingsPage> createState() => _ClientSettingsPageState();
}

class _ClientSettingsPageState extends State<ClientSettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),),
            Divider(color: Theme.of(context).colorScheme.primary,),
            Table(
              columnWidths: const {
                0 : FractionColumnWidth(0.75),
                1 : FractionColumnWidth(0.25)
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    TableCell(child: Text('Show Notifications', style: Theme.of(context).textTheme.bodySmall,),),
                    TableCell(
                      child: Switch(
                        value: SettingsUtil.isNotifOn, 
                        onChanged: (value) async{
                          setState(() {
                            SettingsUtil.isNotifOn = value;
                          });
                          await SettingsUtil.saveNotifSetting(value);
                          if (!value) {
                            await NotificationsStudentService().notifPlugin.cancelAll();
                          }
                          else {
                            await NotificationsStudentService().rescheduleAllNotifications();
                          }
                        }
                      ),
                    )
                  ]
                ),
                TableRow(
                  children: [
                    TableCell(child: Text('Buffer time before class notification (minutes)', style: Theme.of(context).textTheme.bodySmall,),),
                    TableCell(
                      child: DropdownButton<int>(
                        value: SettingsUtil.buffers[SettingsUtil.bufferIndex],
                        items: SettingsUtil.buffers.map((int buffer) {
                          return DropdownMenuItem<int>(
                            value: buffer,
                            child: Text(buffer.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            int newIndex = SettingsUtil.buffers.indexOf(newValue);
                            setState(() {
                              SettingsUtil.bufferIndex = newIndex;
                            });
                            SettingsUtil.saveBufferIndex(newIndex);
                          }
                        },
                      ),
                    )
                  ]
                )
              ],
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (context) => const ChangePasswordDialog()
                );
              }, 
              child: Text(
                'Change Password', 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary, 
                  fontWeight: FontWeight.bold
                ),
              )
            ),
            TextButton(
              onPressed: () => AuthService().signOut(), 
              child: Text(
                'Logout', 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red, 
                  fontWeight: FontWeight.bold
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}