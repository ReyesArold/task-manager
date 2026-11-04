import 'package:flutter/material.dart';

enum TaskFilter {
  completed(Icons.check_circle_outline, Colors.green),
  overdue(Icons.warning_amber_outlined, Colors.red),
  today(Icons.today_outlined, Colors.blue);

  final IconData icon;
  final Color color;

  const TaskFilter(this.icon, this.color);
}