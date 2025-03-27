import 'package:class_sched/services/auth_service.dart';
import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';

class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reloadPage,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FutureBuilder(
          future: ClientDBManager().getCurrentInstructorInfo(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(50),
                child: LinearProgressIndicator(),
              ),);
            }
            else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()),);
            }
            final instructorData = snapshot.data as Map<String, dynamic>;
            
            return Column(
              children: [
                Center(
                  child: Icon(
                    Icons.person, 
                    size: 200,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                ),
                Text(
                  '${instructorData['last_name']}, ${instructorData['first_name']} ${instructorData['middle_name'].toString().isNotEmpty ? instructorData['middle_name'].toString().substring(0,1) : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Table(
                    columnWidths: const {
                      0 : FractionColumnWidth(0.3),
                      1 : FractionColumnWidth(0.7)
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'Email: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            instructorData['email'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Status: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            instructorData['is_full_time'] ? 'Full Time' : 'Part Time',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                      TableRow(
                        children: [
                          Text(
                            'Sex: ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            instructorData['sex'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
              ]
            );
          }
        ),
      ),
    );
  }
  Future<void> _reloadPage() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {});
  }
}