enum TaskPriority { high, medium, low }

enum TaskStatus { todo, inProgress, done }

class TaskExtras {
  TaskExtras({
    required this.taskId,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.assignedUserId,
    this.assignedUserName,
    this.category,
    this.reminderDate,
  });

  final int taskId;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final int? assignedUserId;
  final String? assignedUserName;
  final String? category;
  final DateTime? reminderDate;

  TaskExtras copyWith({
    int? taskId,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    int? assignedUserId,
    String? assignedUserName,
    String? category,
    DateTime? reminderDate,
  }) {
    return TaskExtras(
      taskId: taskId ?? this.taskId,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      category: category ?? this.category,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
}
