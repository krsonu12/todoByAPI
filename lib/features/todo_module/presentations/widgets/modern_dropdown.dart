import 'package:flutter/material.dart';

import '../shared/design_system.dart';

class ModernDropdown<T> extends StatelessWidget {
  const ModernDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
    required this.icon,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TodoDesignSystem.spacing16,
        vertical: TodoDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: TodoDesignSystem.neutralGray50,
        borderRadius: BorderRadius.circular(TodoDesignSystem.radiusMedium),
        border: Border.all(color: TodoDesignSystem.neutralGray200),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: TodoDesignSystem.bodyMedium.copyWith(
          color: TodoDesignSystem.neutralGray900,
        ),
        dropdownColor: Colors.white,
      ),
    );
  }
}
