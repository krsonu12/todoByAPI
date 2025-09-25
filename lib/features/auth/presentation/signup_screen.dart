import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../todo_module/presentations/shared/design_system.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthBrandHeader(),
                const SizedBox(height: TodoDesignSystem.spacing12),
                const AuthHighlights(),
                const SizedBox(height: TodoDesignSystem.spacing16),
                AuthCard(
                  title: 'Create account',
                  icon: Icons.person_add_alt_1_rounded,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: TodoDesignSystem.spacing8),
                        Text(
                          'Join to manage your todos.',
                          textAlign: TextAlign.center,
                          style: TodoDesignSystem.bodyMedium.copyWith(
                            color: TodoDesignSystem.neutralGray600,
                          ),
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing24),
                        AuthTextField(
                          controller: _usernameCtrl,
                          label: 'Username',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: TodoDesignSystem.spacing12),
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
                                        .register(
                                          username: _usernameCtrl.text.trim(),
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
                                    'Create account',
                                    style: TodoDesignSystem.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
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
                              'Already have an account? ',
                              style: TodoDesignSystem.bodySmall.copyWith(
                                color: TodoDesignSystem.neutralGray700,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/signin'),
                              child: const Text('Sign in'),
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
