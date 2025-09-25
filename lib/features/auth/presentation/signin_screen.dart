import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../todo_module/presentations/shared/design_system.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_widgets.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: TodoDesignSystem.neutralGray50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TodoDesignSystem.spacing24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthBrandHeader(),
                const SizedBox(height: TodoDesignSystem.spacing12),
                const AuthHighlights(),
                const SizedBox(height: TodoDesignSystem.spacing16),
                AuthCard(
                  title: 'Sign in',
                  icon: Icons.lock_rounded,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: TodoDesignSystem.spacing8),
                        Text(
                          'Welcome back! Sign in to continue.',
                          textAlign: TextAlign.center,
                          style: TodoDesignSystem.bodyMedium.copyWith(
                            color: TodoDesignSystem.neutralGray600,
                          ),
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing24),
                        AuthTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing12),
                        AuthTextField(
                          controller: _passwordCtrl,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing20),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: state is AsyncLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .login(
                                          email: _emailCtrl.text.trim(),
                                          password: _passwordCtrl.text,
                                        );
                                    if (!mounted) return;
                                    final current = ref.read(
                                      authControllerProvider,
                                    );
                                    if (current is! AsyncError)
                                      context.go('/home');
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TodoDesignSystem.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  TodoDesignSystem.radiusMedium,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: state is AsyncLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Sign in',
                                    style: TodoDesignSystem.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing12),
                        if (state is AsyncError)
                          Text(
                            state.error.toString(),
                            style: TodoDesignSystem.bodySmall.copyWith(
                              color: TodoDesignSystem.errorRed,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: TodoDesignSystem.spacing12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TodoDesignSystem.bodySmall.copyWith(
                                color: TodoDesignSystem.neutralGray700,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/signup'),
                              child: const Text('Create one'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
