import 'package:flutter/material.dart';

class SchedulesByCoursePage extends StatefulWidget {
  final Map<String, dynamic> course;
  const SchedulesByCoursePage({super.key, required this.course});

  @override
  State<SchedulesByCoursePage> createState() => _SchedulesByCoursePageState();
}

class _SchedulesByCoursePageState extends State<SchedulesByCoursePage> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.course['short_form']);
  }
}