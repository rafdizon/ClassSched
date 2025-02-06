import 'package:flutter/material.dart';

final students = [
  {
    'student_id': '20221023',
    'first_name': 'John',
    'last_name': 'Doe',
    'year': 3,
    'course' : 'Bachelor of Science in Computer Science',
    'gender' : 'Male',
    'password' : 'passWord.123'
  },
  {
    'student_id': '20232891',
    'first_name': 'Sabrina',
    'last_name': 'Carpenter',
    'year': 2,
    'course' : 'Bachelor of Science in Business Administration',
    'gender' : 'Female',
    'password' : 'PassWord_321'
  },
];

final notification = [
  {
    'notif_id' : '0012',
    'student_id' : '20232891',
    'header' : 'Report: Schedule not available',
    'body' : 'Schedule is not showing up in my profile'
  },
  {
    'notif_id' : '0014',
    'student_id' : '20232891',
    'header' : 'Report: Schedule still not available',
    'body' : ''
  },
];

final schoolSettings = [
  {
    'school_year' : [
      '2022-2023', '2023-2024', '2024-2025'
    ],
    'semester' : [
      'Semester 1', 'Semester 2', 'Summer'
    ],
    'program_level' : [
      'Bachelor of Science'
    ],
    'program' : [
      'Computer Science', 'Business Administration', 'Secondary Education', 'Elementary Education'
    ],
    'year_level' : [
      '1st Year', '2nd Year', '3rd Year', '4th Year'
    ],
    'section' : [
      'A', 'B','C','D'
    ],
  }
];

List<String> dashboardCategories = [
  'Student Accounts', 
  'Employee Accounts', 
  'Adding, Dropping, & Changing Schedule', 
  'Advisory Class Management'
]; 

List<IconData> dashboardIcons = [
  Icons.person, Icons.group, Icons.calendar_month, Icons.school
];