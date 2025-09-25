import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_system.dart';

class AnimatedTaskCard extends StatefulWidget {
  const AnimatedTaskCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation = 0,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TodoDesignSystem.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: TodoDesignSystem.curveDefault,
      ),
    );
    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation,
          end: widget.elevation + 2,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: TodoDesignSystem.curveDefault,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius:
                  widget.borderRadius ??
                  BorderRadius.circular(TodoDesignSystem.radiusMedium),
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(TodoDesignSystem.radiusMedium),
                child: Container(
                  padding:
                      widget.padding ??
                      const EdgeInsets.all(TodoDesignSystem.spacing16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedTaskCheckbox extends StatefulWidget {
  const AnimatedTaskCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24.0,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  State<AnimatedTaskCheckbox> createState() => _AnimatedTaskCheckboxState();
}

class _AnimatedTaskCheckboxState extends State<AnimatedTaskCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TodoDesignSystem.animationMedium,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: TodoDesignSystem.curveSpring),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedTaskCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.value
                    ? TodoDesignSystem.primaryBlue
                    : TodoDesignSystem.neutralGray300,
                width: 2,
              ),
              color: widget.value
                  ? TodoDesignSystem.primaryBlue
                  : Colors.transparent,
            ),
            child: widget.value
                ? Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      Icons.check,
                      size: widget.size * 0.7,
                      color: Colors.white,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class AnimatedPriorityChip extends StatefulWidget {
  const AnimatedPriorityChip({
    super.key,
    required this.priority,
    required this.label,
    this.onTap,
  });

  final String priority;
  final String label;
  final VoidCallback? onTap;

  @override
  State<AnimatedPriorityChip> createState() => _AnimatedPriorityChipState();
}

class _AnimatedPriorityChipState extends State<AnimatedPriorityChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TodoDesignSystem.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: TodoDesignSystem.curveDefault,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = TodoDesignSystem.getPriorityColor(widget.priority);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TodoDesignSystem.spacing12,
                vertical: TodoDesignSystem.spacing4,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  TodoDesignSystem.radiusSmall,
                ),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: TodoDesignSystem.spacing4),
                  Text(
                    widget.label,
                    style: TodoDesignSystem.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedSkeleton extends StatefulWidget {
  const AnimatedSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<AnimatedSkeleton> createState() => _AnimatedSkeletonState();
}

class _AnimatedSkeletonState extends State<AnimatedSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(TodoDesignSystem.radiusSmall),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                TodoDesignSystem.neutralGray200,
                TodoDesignSystem.neutralGray100,
                TodoDesignSystem.neutralGray200,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedSlideItem extends StatefulWidget {
  const AnimatedSlideItem({
    super.key,
    required this.child,
    required this.index,
    this.delay,
  });

  final Widget child;
  final int index;
  final Duration? delay;

  @override
  State<AnimatedSlideItem> createState() => _AnimatedSlideItemState();
}

class _AnimatedSlideItemState extends State<AnimatedSlideItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TodoDesignSystem.animationMedium,
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: TodoDesignSystem.curveDefault,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: TodoDesignSystem.curveDefault,
      ),
    );
    final delay = widget.delay ?? Duration(milliseconds: 50 * widget.index);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
        );
      },
    );
  }
}

class AnimatedMorphingFAB extends StatefulWidget {
  const AnimatedMorphingFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<AnimatedMorphingFAB> createState() => _AnimatedMorphingFABState();
}

class _AnimatedMorphingFABState extends State<AnimatedMorphingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TodoDesignSystem.animationMedium,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: TodoDesignSystem.curveDefault,
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: TodoDesignSystem.curveDefault,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? TodoDesignSystem.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: TodoDesignSystem.shadowMedium,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.foregroundColor ?? Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
