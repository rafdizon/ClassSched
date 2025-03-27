import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

String convertDayToRRule(String day) {
  switch (day) {
    case 'M': return 'MO';
    case 'T': return 'TU';
    case 'W': return 'WE';
    case 'Th': return 'TH';
    case 'F': return 'FR';
    case 'Sa': return 'SA';
    case 'Su': return 'SU';
    default: return '';
  }
}

List<DateTime> computeAllOccurrences(Appointment appointment, DateTime cycleStart, DateTime cycleEnd) {
  final ruleParts = appointment.recurrenceRule?.split(';') ?? [];
  List<int> recurrenceWeekdays = [];
  final daysMap = {
    'MO': DateTime.monday,
    'TU': DateTime.tuesday,
    'WE': DateTime.wednesday,
    'TH': DateTime.thursday,
    'FR': DateTime.friday,
    'SA': DateTime.saturday,
    'SU': DateTime.sunday,
  };

  for (final part in ruleParts) {
    if (part.startsWith('BYDAY=')) {
      final daysStr = part.substring(6);
      final dayAbbrs = daysStr.split(',');
      for (final abbr in dayAbbrs) {
        if (daysMap.containsKey(abbr)) {
          recurrenceWeekdays.add(daysMap[abbr]!);
        }
      }
    }
  }
  recurrenceWeekdays.sort();

  final appointmentTime = TimeOfDay.fromDateTime(appointment.startTime);
  List<DateTime> occurrences = [];
  DateTime candidate = cycleStart;

  while (!candidate.isAfter(cycleEnd)) {
    if (recurrenceWeekdays.contains(candidate.weekday)) {
      final candidateWithTime = DateTime(
        candidate.year,
        candidate.month,
        candidate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );
      if (candidateWithTime.isAfter(DateTime.now())) {
        occurrences.add(candidateWithTime);
      }
    }
    candidate = candidate.add(const Duration(days: 1));
  }
  return occurrences;
}

Appointment cloneAppointmentWithNewStartTime(Appointment appointment, DateTime newStart) {
  final duration = appointment.endTime.difference(appointment.startTime);
  return Appointment(
    startTime: newStart,
    endTime: newStart.add(duration),
    subject: appointment.subject,
    recurrenceRule: appointment.recurrenceRule,
    color: appointment.color,
    isAllDay: appointment.isAllDay,
    notes: appointment.notes,
  );
}