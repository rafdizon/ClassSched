import 'package:class_sched/services/admin_db_manager.dart';
import 'package:class_sched/services/password_generator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AddInstructorDialog extends StatefulWidget {
  const AddInstructorDialog({super.key});

  @override
  State<AddInstructorDialog> createState() => _AddInstructorDialogState();
}

class _AddInstructorDialogState extends State<AddInstructorDialog> {
  var _selectedSex;
  var _selectedStatus;
  final _sexList = ['Male', 'Female',];
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedSex = null;
    _selectedStatus = null;
  }
    Future sendEmail({required String email, required String name, required String password}) async {
    final response = await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: {
        'accept' : 'application/json',
        'api-key' : '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',
        'content-type': 'application/json'
      },
      body: jsonEncode({
        "sender": {"name": "ClassSched SPUSM", "email": "classschedspusm@gmail.com"},
        "to": [{"email": email, "name": name}],
        "subject": "ClassSched SPUSM Account",
        "textContent": "Login to your ClassSched SPUSM account using these credentials:\nEmail: $email\nPassword: $password\n\nDON'T SHARE THESE TO ANYONE, CHANGE YOUR PASSWORD IMMEDIATELY!",
      })
    );

      if (response.statusCode == 201) {
        logger.d('Email sent successfully!');
      } else {
        logger.d('Failed: ${response.body}');
      }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a instructor: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(overflow: TextOverflow.ellipsis),),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth()
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'E-mail Address*', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password*', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              child: TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _passwordController.text = generatePassword();
                            }, 
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.refresh)
                          )
                        ],
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'First Name*', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _fnameController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                  
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Middle Name', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _mnameController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Last Name*', 
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: TextField(
                          controller: _lnameController,
                          decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, -15, 10, 0)
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ),
                    ],
                  ),
                ],
              ),
              Table(
                columnWidths: const {
                  0: FractionColumnWidth(0.45),
                  1: FractionColumnWidth(0.05),
                  2: FractionColumnWidth(0.50),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      SizedBox(
                        height: 30,
                        child: DropdownButton(
                          hint: Text('Select Sex...', style: Theme.of(context).textTheme.bodySmall,),
                          value: _selectedSex,
                          items: _sexList.map((sex) {
                            return DropdownMenuItem(value: sex, child: Text(sex, style: Theme.of(context).textTheme.bodySmall,));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSex = newValue;
                            });
                          },
                          isExpanded: true,
                        )
                      ),
                      const SizedBox(),
                      SizedBox(
                        height: 30,
                        child: DropdownButton(
                          hint: Text('instructor Status...', style: Theme.of(context).textTheme.bodySmall,),
                          value: _selectedStatus,
                          items: ['Full Time', 'Part Time'].map((status) {
                            return DropdownMenuItem(value: status, child: Text(status, style: Theme.of(context).textTheme.bodySmall,));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedStatus = newValue;
                            });
                          },
                          isExpanded: true,
                        )
                      ),
                    ]
                  )
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    }, 
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                  TextButton(
                    onPressed: () async {
                      if(_selectedStatus != null && _emailController.text != '' && _passwordController.text != '' && _fnameController.text != '' && _lnameController.text != ''){
                        setState(() {
                          _isLoading = true;
                        });
                        final error = await AdminDBManager().registerInstructor(
                          fName: _fnameController.text,
                          mName: _mnameController.text,
                          lName: _lnameController.text,
                          email: _emailController.text,
                          pw: _passwordController.text,
                          sex: _selectedSex,
                          isFullTime: _selectedStatus == 'Full Time' ? true : false,
                          context: context 
                        );
                        await sendEmail(
                          email: _emailController.text, 
                          name: '${_fnameController.text} ${_lnameController.text}', 
                          password: _passwordController.text
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        
                        if(error != null && mounted){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $error'), backgroundColor: Colors.red));
                        }
                        else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully added instructor!'), backgroundColor: Theme.of(context).colorScheme.primary));
                        }
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill * required fields'), backgroundColor: Colors.red));
                      }
                    }, 
                    child: _isLoading 
                    ? const CircularProgressIndicator()
                    : Text(
                      'Save Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}