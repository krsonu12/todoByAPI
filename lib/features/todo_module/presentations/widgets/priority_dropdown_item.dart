import 'package:flutter/material.dart';

import '../../data/local_db/task_extras.dart';
import '../shared/design_system.dart';

class PriorityDropdownItem extends StatelessWidget {
  const PriorityDropdownItem({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: TodoDesignSystem.getPriorityColor(priority.name),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: TodoDesignSystem.spacing8),
        Flexible(
          child: Text(
            _getPriorityLabel(priority),
            style: TextStyle(color: TodoDesignSystem.neutralGray900),
          ),
        ),
      ],
    );
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
