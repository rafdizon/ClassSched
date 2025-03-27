import 'package:class_sched/services/client_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
    final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final newPassword = _newPasswordController.text.trim();

    try {
      final response = await ClientDBManager().database.auth.updateUser(
        UserAttributes(password: newPassword)
      );
      if(response.user == null) {
        setState(() {
          _errorMessage = "Password update failed. Please try again.";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully.")),
        );
        Navigator.pop(context);
      }
    }
    catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Text('Change Password', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Divider(color: Theme.of(context).colorScheme.primary,),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: "New Password",
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  border: const OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.bodySmall,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a new password";
                  }
                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  final RegExp lowerCaseRegExp = RegExp(r'[a-z]');
                  final RegExp upperCaseRegExp = RegExp(r'[A-Z]');
                  final RegExp digitRegExp = RegExp(r'\d');
                  final RegExp symbolRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>_]');
                  
                  if (!lowerCaseRegExp.hasMatch(value)) {
                    return "Include at least one small letter";
                  }
                  if (!upperCaseRegExp.hasMatch(value)) {
                    return "Include at least one capital letter";
                  }
                  if (!digitRegExp.hasMatch(value)) {
                    return "Include at least one number";
                  }
                  if (!symbolRegExp.hasMatch(value)) {
                    return "Include at least one symbol";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  border: const OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.bodySmall,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your new password";
                  }
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: _changePassword,
                      child: Text(
                        "Update Password", 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}