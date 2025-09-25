import 'package:flutter/material.dart';

import '../shared/design_system.dart';

class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TodoDesignSystem.labelLarge.copyWith(
            color: TodoDesignSystem.neutralGray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: TodoDesignSystem.spacing12),
        child,
      ],
    );
  }
}
