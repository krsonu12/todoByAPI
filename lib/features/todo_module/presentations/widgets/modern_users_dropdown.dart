import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/users_repository.dart';
import '../shared/design_system.dart';

/// A modern users dropdown with avatar display
class ModernUsersDropdown extends ConsumerWidget {
  const ModernUsersDropdown({
    super.key,
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
      return _buildDropdown(prefetched!);
    }

    return FutureBuilder<List<AppUser>>(
      future: ref.read(usersRepositoryProvider).getUsers(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _buildLoadingState();
        }
        return _buildDropdown(snap.data!);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(TodoDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: TodoDesignSystem.neutralGray50,
        borderRadius: BorderRadius.circular(TodoDesignSystem.radiusMedium),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<AppUser> users) {
    final items = [
      DropdownMenuItem<AppUser>(
        value: null,
        child: Text(
          'Unassigned',
          style: TextStyle(color: TodoDesignSystem.neutralGray900),
        ),
      ),
      ...users.map((u) => _buildUserMenuItem(u)),
    ];

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
      child: DropdownButtonFormField<AppUser>(
        initialValue: initial,
        items: items,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Assignee',
          prefixIcon: Icon(Icons.person_rounded, size: 20),
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

  DropdownMenuItem<AppUser> _buildUserMenuItem(AppUser user) {
    return DropdownMenuItem<AppUser>(
      value: user,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: TodoDesignSystem.secondaryPurple.withOpacity(0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TodoDesignSystem.labelSmall.copyWith(
                color: TodoDesignSystem.secondaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: TodoDesignSystem.spacing8),
          Flexible(
            child: Text(
              user.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: TodoDesignSystem.neutralGray900),
            ),
          ),
        ],
      ),
    );
  }
}
