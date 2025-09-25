import 'package:flutter/material.dart';

import '../../../todo_module/presentations/shared/design_system.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TodoDesignSystem.radiusXLarge),
        boxShadow: TodoDesignSystem.shadowLarge,
      ),
      padding: const EdgeInsets.all(TodoDesignSystem.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(TodoDesignSystem.spacing8),
                decoration: BoxDecoration(
                  color: TodoDesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    TodoDesignSystem.radiusSmall,
                  ),
                ),
                child: Icon(
                  icon,
                  color: TodoDesignSystem.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: TodoDesignSystem.spacing8),
              Text(
                title,
                style: TodoDesignSystem.headingSmall.copyWith(
                  color: TodoDesignSystem.neutralGray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: TodoDesignSystem.spacing24),
          child,
        ],
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TodoDesignSystem.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: TodoDesignSystem.neutralGray50,
        border: InputBorder.none,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}

class AuthHighlights extends StatelessWidget {
  const AuthHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    const List<(IconData, String)> items = <(IconData, String)>[
      (Icons.check_circle_rounded, 'Track tasks effortlessly'),
      (Icons.schedule_rounded, 'Set reminders and due dates'),
      (Icons.people_alt_rounded, 'Assign and collaborate'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: TodoDesignSystem.spacing16),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final (iconData, label) = entry.value;
          final Color iconColor = switch (idx) {
            0 => TodoDesignSystem.successGreen,
            1 => TodoDesignSystem.warningOrange,
            _ => TodoDesignSystem.secondaryPurple,
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: TodoDesignSystem.spacing8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      TodoDesignSystem.radiusSmall,
                    ),
                  ),
                  child: Icon(iconData, size: 16, color: iconColor),
                ),
                const SizedBox(width: TodoDesignSystem.spacing8),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TodoDesignSystem.bodySmall.copyWith(
                      color: TodoDesignSystem.neutralGray700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TodoDesignSystem.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TodoDesignSystem.radiusLarge),
          ),
          child: const Icon(
            Icons.task_alt_rounded,
            color: TodoDesignSystem.primaryBlue,
            size: 28,
          ),
        ),
        const SizedBox(height: TodoDesignSystem.spacing8),
        Text(
          'Todo App',
          style: TodoDesignSystem.headingSmall.copyWith(
            color: TodoDesignSystem.neutralGray900,
          ),
        ),
      ],
    );
  }
}
