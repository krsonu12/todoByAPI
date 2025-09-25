import 'package:flutter/material.dart';

import '../../data/local_db/task_extras.dart';
import '../shared/design_system.dart';

class StatusDropdownItem extends StatelessWidget {
  const StatusDropdownItem({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getStatusIcon(status),
          size: 16,
          color: TodoDesignSystem.getStatusColor(status.name),
        ),
        const SizedBox(width: TodoDesignSystem.spacing8),
        Flexible(
          child: Text(
            _getStatusLabel(status),
            style: TextStyle(color: TodoDesignSystem.neutralGray900),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.hourglass_empty_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}
