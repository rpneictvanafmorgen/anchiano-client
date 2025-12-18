import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';
import 'package:anchiano_client/bloc/auth/auth_bloc.dart';
import 'package:anchiano_client/bloc/auth/auth_event.dart';
import 'package:anchiano_client/bloc/auth/auth_state.dart';

import 'widgets/app_scaffold.dart';

class LoginPage extends StatefulWidget {
  final String? error;
  final void Function(Locale locale) onChangeLanguage;

  const LoginPage({
    super.key,
    this.error,
    required this.onChangeLanguage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isRegister = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  String _localizedAuthError(AppLocalizations t, String? key) {
    if (key == null || key.isEmpty) return '';
    switch (key) {
      case 'authErrorLogin':
        return t.authErrorLogin;
      case 'authErrorRegister':
        return t.authErrorRegister;
      default:
        return key;
    }
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isRegister) {
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.formErrorMissingFields)));
        return;
      }
      context.read<AuthBloc>().add(AuthLoginRequested(email, password));
      return;
    }

    final displayName = _nameController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    if (displayName.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.formErrorMissingFields)));
      return;
    }
    if (password != repeatPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.formErrorPasswordsNotMatching)));
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            displayName: displayName,
            email: email,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppScaffold(
      title: _isRegister ? t.registerTitle : t.loginTitle,
      showLogout: false,
      onChangeLanguage: widget.onChangeLanguage,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final errorKey = state is AuthUnauthenticated ? state.error : widget.error;
          final errorText = _localizedAuthError(t, errorKey);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                if (_isRegister) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: t.registerNameLabel),
                  ),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: t.loginEmailLabel),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: t.loginPasswordLabel),
                  obscureText: true,
                ),

                if (_isRegister) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repeatPasswordController,
                    decoration: InputDecoration(labelText: t.registerRepeatPasswordLabel),
                    obscureText: true,
                  ),
                ],

                const SizedBox(height: 18),

                ElevatedButton(
                  onPressed: state is AuthChecking ? null : _submit,
                  child: Text(_isRegister ? t.registerButton : t.loginButton),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => setState(() => _isRegister = !_isRegister),
                  child: Text(_isRegister ? t.loginTitle : t.loginRegisterLink),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
