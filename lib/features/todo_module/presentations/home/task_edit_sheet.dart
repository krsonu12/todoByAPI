import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_db/task_extras.dart';
import '../../domain/users_repository.dart';
import '../shared/design_system.dart';
import '../widgets/index.dart';

class TaskFormResult {
  TaskFormResult({
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.assignedUserId,
    this.assignedUserName,
  });

  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final int? assignedUserId;
  final String? assignedUserName;
}

class TaskEditSheet extends ConsumerStatefulWidget {
  const TaskEditSheet({super.key, this.initial, this.prefetchedUsers});
  final TaskFormResult? initial;
  final List<AppUser>? prefetchedUsers;

  @override
  ConsumerState<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends ConsumerState<TaskEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  AppUser? _assigned;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _description = TextEditingController(
      text: widget.initial?.description ?? '',
    );
    _dueDate = widget.initial?.dueDate;
    _priority = widget.initial?.priority ?? TaskPriority.medium;
    _status = widget.initial?.status ?? TaskStatus.todo;
    if (widget.initial?.assignedUserId != null) {
      _assigned = AppUser(
        id: widget.initial!.assignedUserId!,
        name:
            widget.initial!.assignedUserName ??
            'User ${widget.initial!.assignedUserId}',
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedContainer(
      duration: TodoDesignSystem.animationMedium,
      curve: TodoDesignSystem.curveDefault,
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TodoDesignSystem.radiusXLarge),
          ),
          boxShadow: TodoDesignSystem.shadowLarge,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(TodoDesignSystem.spacing24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with drag handle
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: TodoDesignSystem.neutralGray300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                TodoDesignSystem.spacing8,
                              ),
                              decoration: BoxDecoration(
                                color: TodoDesignSystem.primaryBlue.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  TodoDesignSystem.radiusSmall,
                                ),
                              ),
                              child: Icon(
                                widget.initial == null
                                    ? Icons.add_task_rounded
                                    : Icons.edit_rounded,
                                color: TodoDesignSystem.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: TodoDesignSystem.spacing12),
                            Expanded(
                              child: Text(
                                widget.initial == null
                                    ? 'Create New Task'
                                    : 'Edit Task',
                                style: TodoDesignSystem.headingSmall.copyWith(
                                  color: TodoDesignSystem.neutralGray900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(
                                  TodoDesignSystem.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: TodoDesignSystem.neutralGray100,
                                  borderRadius: BorderRadius.circular(
                                    TodoDesignSystem.radiusSmall,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: TodoDesignSystem.neutralGray600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: TodoDesignSystem.spacing24),
                    // Title Field
                    FormSection(
                      title: 'Task Details',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _title,
                            style: TodoDesignSystem.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              hintText: 'What needs to be done?',
                              prefixIcon: const Icon(Icons.title_rounded),
                              filled: true,
                              fillColor: TodoDesignSystem.neutralGray50,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: TodoDesignSystem.spacing16),
                          TextFormField(
                            controller: _description,
                            maxLines: 3,
                            style: TodoDesignSystem.bodyMedium,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Add more details about this task...',
                              prefixIcon: const Icon(Icons.description_rounded),
                              filled: true,
                              fillColor: TodoDesignSystem.neutralGray50,
                              alignLabelWithHint: true,
                            ),
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TodoDesignSystem.spacing20),
                    // Task Properties
                    FormSection(
                      title: 'Task Properties',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ModernDateField(
                                  value: _dueDate,
                                  onPick: (d) => setState(() => _dueDate = d),
                                ),
                              ),
                              const SizedBox(width: TodoDesignSystem.spacing12),
                              Expanded(
                                child: ModernDropdown<TaskPriority>(
                                  value: _priority,
                                  items: TaskPriority.values
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: PriorityDropdownItem(
                                            priority: p,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(
                                    () => _priority = v ?? _priority,
                                  ),
                                  label: 'Priority',
                                  icon: Icons.flag_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TodoDesignSystem.spacing16),
                          Row(
                            children: [
                              Expanded(
                                child: ModernDropdown<TaskStatus>(
                                  value: _status,
                                  items: TaskStatus.values
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: StatusDropdownItem(status: s),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _status = v ?? _status),
                                  label: 'Status',
                                  icon: Icons.work_rounded,
                                ),
                              ),
                              const SizedBox(width: TodoDesignSystem.spacing12),
                              Expanded(
                                child: ModernUsersDropdown(
                                  initial: _assigned,
                                  onChanged: (u) =>
                                      setState(() => _assigned = u),
                                  prefetched: widget.prefetchedUsers,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TodoDesignSystem.spacing32),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: TodoDesignSystem.spacing16,
                              ),
                              side: BorderSide(
                                color: TodoDesignSystem.neutralGray300,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TodoDesignSystem.labelLarge.copyWith(
                                color: TodoDesignSystem.neutralGray600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: TodoDesignSystem.spacing12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              HapticFeedback.mediumImpact();
                              final result = TaskFormResult(
                                title: _title.text.trim(),
                                description: _description.text.trim(),
                                dueDate: _dueDate,
                                priority: _priority,
                                status: _status,
                                assignedUserId: _assigned?.id,
                                assignedUserName: _assigned?.name,
                              );
                              Navigator.pop(context, result);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TodoDesignSystem.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: TodoDesignSystem.spacing16,
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.initial == null
                                      ? Icons.add_rounded
                                      : Icons.save_rounded,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: TodoDesignSystem.spacing8,
                                ),
                                Text(
                                  widget.initial == null
                                      ? 'Create Task'
                                      : 'Save Changes',
                                  style: TodoDesignSystem.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
