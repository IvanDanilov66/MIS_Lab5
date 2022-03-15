import 'package:flutter/material.dart';

class ScheduledExam {
  final String name;
  final DateTime dateTime;
  final TimeOfDay timeOfDay;

  ScheduledExam(this.name, this.dateTime, this.timeOfDay);
}
