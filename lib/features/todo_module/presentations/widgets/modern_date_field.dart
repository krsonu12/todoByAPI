import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/design_system.dart';

/// A modern date picker field with enhanced styling
class ModernDateField extends StatelessWidget {
  const ModernDateField({super.key, required this.value, required this.onPick});

  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 5),
          initialDate: value ?? now,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: TodoDesignSystem.primaryBlue),
              ),
              child: child!,
            );
          },
        );
        onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(TodoDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: TodoDesignSystem.neutralGray50,
          borderRadius: BorderRadius.circular(TodoDesignSystem.radiusMedium),
          border: Border.all(color: TodoDesignSystem.neutralGray200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: TodoDesignSystem.neutralGray600,
            ),
            const SizedBox(width: TodoDesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Due Date',
                    style: TodoDesignSystem.labelSmall.copyWith(
                      color: TodoDesignSystem.neutralGray600,
                    ),
                  ),
                  const SizedBox(height: TodoDesignSystem.spacing2),
                  Text(
                    value == null ? 'No due date' : _formatDate(value!),
                    style: TodoDesignSystem.bodyMedium.copyWith(
                      color: value == null
                          ? TodoDesignSystem.neutralGray500
                          : TodoDesignSystem.neutralGray900,
                    ),
                  ),
                ],
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPick(null);
                },
                child: Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: TodoDesignSystem.neutralGray400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }
}
