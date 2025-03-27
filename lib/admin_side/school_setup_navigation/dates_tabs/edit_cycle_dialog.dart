import 'package:flutter/material.dart';
import 'package:class_sched/services/admin_db_manager.dart';

class EditCycleDialog extends StatefulWidget {
  final Map<String, dynamic> cycleData;
  final int semId;
  const EditCycleDialog({Key? key, required this.cycleData, required this.semId})
      : super(key: key);

  @override
  State<EditCycleDialog> createState() => _EditCycleDialogState();
}

class _EditCycleDialogState extends State<EditCycleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cycleNoController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  final adminDBManager = AdminDBManager();

  @override
  void initState() {
    super.initState();
    _cycleNoController = TextEditingController(
        text: widget.cycleData['cycle_no']?.toString() ?? '');
    _startDateController =
        TextEditingController(text: widget.cycleData['start_date'] ?? '');
    _endDateController =
        TextEditingController(text: widget.cycleData['end_date'] ?? '');
  }

  @override
  void dispose() {
    _cycleNoController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineMedium: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14),
            ),
          ),
          child: child!,
        );
      },
    );
    if (_picked != null) {
      String newDate = _picked.toString().split(" ")[0];
      setState(() {
        _startDateController.text = newDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              headlineMedium: TextStyle(fontSize: 20),
              titleLarge: TextStyle(fontSize: 16),
              bodyLarge: TextStyle(fontSize: 14),
            ),
          ),
          child: child!,
        );
      },
    );
    if (_picked != null) {
      String newDate = _picked.toString().split(" ")[0];
      setState(() {
        _endDateController.text = newDate;
      });
    }
  }

  Future<void> _saveCycle() async {
    if (_formKey.currentState!.validate()) {
      // Update the cycle in your database.
      final error = await adminDBManager.updateCycle(
        id: widget.cycleData['id'],
        cycleNo: _cycleNoController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
      );
      if (error == null) {
        Navigator.of(context).pop(true); // success flag
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Cycle', style: Theme.of(context).textTheme.bodyMedium),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                controller: _cycleNoController,
                decoration: InputDecoration(
                  labelText: 'Cycle No',
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter cycle number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectStartDate,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select start date' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectEndDate,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select end date' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        TextButton(
          onPressed: _saveCycle,
          child: Text('Save',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }
}
