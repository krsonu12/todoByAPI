import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_extras.dart';
import '../../domain/users_repository.dart';

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
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.initial == null ? 'New Task' : 'Edit Task',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            value: _dueDate,
                            onPick: (d) => setState(() => _dueDate = d),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<TaskPriority>(
                            initialValue: _priority,
                            items: TaskPriority.values
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(_priorityLabel(p)),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _priority = v ?? _priority),
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskStatus>(
                      initialValue: _status,
                      items: TaskStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_statusLabel(s)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _UsersDropdown(
                      initial: _assigned,
                      onChanged: (u) => setState(() => _assigned = u),
                      prefetched: widget.prefetchedUsers,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
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
                      child: Text(
                        widget.initial == null ? 'Add Task' : 'Save Changes',
                      ),
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

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onPick});
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 5),
          initialDate: value ?? now,
        );
        onPick(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          border: OutlineInputBorder(),
        ),
        child: Text(value == null ? 'None' : _fmt(value!)),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _UsersDropdown extends ConsumerWidget {
  const _UsersDropdown({
    required this.onChanged,
    this.initial,
    this.prefetched,
  });
  final ValueChanged<AppUser?> onChanged;
  final AppUser? initial;
  final List<AppUser>? prefetched;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (prefetched != null) {
      final items = prefetched!
          .map((u) => DropdownMenuItem<AppUser>(value: u, child: Text(u.name)))
          .toList();
      final value = initial == null
          ? null
          : prefetched!.firstWhere(
              (u) => u.id == initial!.id,
              orElse: () => initial!,
            );
      return DropdownButtonFormField<AppUser>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Assigned User',
          border: OutlineInputBorder(),
        ),
      );
    }
    return FutureBuilder<List<AppUser>>(
      future: ref.read(usersRepositoryProvider).getUsers(),
      builder: (context, snap) {
        final items = (snap.data ?? <AppUser>[])
            .map(
              (u) => DropdownMenuItem<AppUser>(value: u, child: Text(u.name)),
            )
            .toList();
        final value = (snap.hasData && initial != null)
            ? (snap.data!.firstWhere(
                (u) => u.id == initial!.id,
                orElse: () => initial!,
              ))
            : null;
        return DropdownButtonFormField<AppUser>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            labelText: 'Assigned User',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
