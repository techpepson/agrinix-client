import 'package:agrinix/providers/auth_provider.dart';
import 'package:agrinix/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/form_field.dart';
import '../../widgets/buttons/submit_button.dart';
import 'dart:developer' as dev;

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthServices authServices = AuthServices();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();

    super.dispose();
  }

  void _onRegister() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _loading = true);
        final request = await authServices.registerService(ref);
        final status = request.statusCode;
        final statusMessage = request.statusMessage;

        if (status == 201) {
          if (mounted) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully'),
                backgroundColor: Colors.green,
              ),
            );

            context.go('/');
          }
        } else {
          if (mounted) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$statusMessage'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
        // await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      dev.log(e.toString());
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            showCloseIcon: true,
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.read(authNotifierProvider.notifier);
    final values = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      Text(
                        'Create your account to get started',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppFormField(
                        label: 'Name',
                        hintText: 'Enter your name',
                        controller: _nameController,
                        onChanged: (p0) {
                          dev.log(values.name.toString(), name: "Name value");
                          provider.updateName(p0);
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Name is required'
                                    : null,
                      ),
                      AppFormField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (p0) {
                          dev.log(values.toString(), name: "Email Value");
                          provider.updateEmail(p0);
                        },
                        validator:
                            (value) =>
                                value == null || !value.contains('@')
                                    ? 'Enter a valid email'
                                    : null,
                      ),
                      AppFormField(
                        helperText:
                            'Your password should include these [@, !, (0-9), (A-Z), (a-z)]',
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (p0) {
                          dev.log(
                            values.password.toString(),
                            name: "Password value",
                          );
                          provider.updatePassword(p0);
                        },
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                      ),
                      AppFormField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator:
                            (value) =>
                                value != _passwordController.text
                                    ? 'Passwords do not match'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      SubmitButton(
                        label: _loading ? 'Registering...' : 'Register',
                        onPressed: _onRegister,
                        loading: _loading,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'or',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {}, // TODO: Add Google register logic
                        icon: Image.asset(
                          'assets/images/google-logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Register with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: Theme.of(context).textTheme.labelLarge,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: Colors.grey),
                          elevation: 2,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/capture-crop.jpg',
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Create Your Agrinix Account',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?'),
        TextButton(
          onPressed: () {
            context.go('/');
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
