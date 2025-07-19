import 'dart:convert';

import 'package:agrinix/core/services/app_services.dart';
import 'package:agrinix/providers/auth_provider.dart';
import 'package:agrinix/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/form_field.dart';
import '../../widgets/buttons/submit_button.dart';
import 'dart:developer' as dev;

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  AuthServices authServices = AuthServices();
  final AppServices appServices = AppServices();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);
      try {
        final request = await authServices.loginService(ref);
        final status = request.statusCode;
        final statusMessage = request.statusMessage;
        final response =
            request.data is String ? jsonDecode(request.data) : request.data;
        final loginStatus = await response['freqStatus'];

        if (status == 201) {
          //set the response token to secure  storage
          await appServices.storage.write(
            key: 'token',
            value: response['token'],
          );

          await appServices.storage.write(
            key: 'userId',
            value: response['userId'],
          );

          if (mounted) {
            if (loginStatus != null && loginStatus == false) {
              context.go('/onboard');
            } else {
              context.go('/discover');
            }
          }
          setState(() => _loading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Successful'),
                backgroundColor: Colors.green,
              ),
            );
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
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);
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
                        'Sign in to your account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppFormField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        onChanged: (p0) {
                          dev.log(values.email);
                          notifier.updateEmail(p0);
                        },
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) =>
                                value == null || !value.contains('@')
                                    ? 'Enter a valid email'
                                    : null,
                      ),
                      AppFormField(
                        onChanged: (p0) {
                          dev.log(values.password);
                          notifier.updatePassword(p0);
                        },
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      SubmitButton(
                        label: _loading ? 'Logging in...' : 'Login',
                        onPressed: _onLogin,
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
                        onPressed: () {}, // TODO: Add Google login logic
                        icon: Image.asset(
                          'assets/images/google-logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Continue with Google'),
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
            'assets/images/farmer-login.jpg',
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome to Agrinix',
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
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
