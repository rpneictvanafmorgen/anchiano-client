import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'widgets/app_scaffold.dart';

class RegisterPage extends StatefulWidget {
  final void Function(Locale locale) onChangeLanguage;

  const RegisterPage({
    super.key,
    required this.onChangeLanguage,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  void _onRegister() {
    final t = AppLocalizations.of(context)!;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pw1 = _passwordController.text;
    final pw2 = _password2Controller.text;

    if (name.isEmpty || email.isEmpty || pw1.isEmpty) {
      setState(() => _localError = t.formErrorMissingFields);
      return;
    }

    if (pw1 != pw2) {
      setState(() => _localError = t.formErrorPasswordsNotMatching);
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            displayName: name,
            email: email,
            password: pw1,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppScaffold(
      title: t.registerTitle,
      onChangeLanguage: widget.onChangeLanguage,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pop(context);
            }
          },
          child: Column(
            children: [
              if (_localError != null)
                Text(
                  _localError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t.registerNameLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: t.loginEmailLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: t.loginPasswordLabel),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password2Controller,
                decoration:
                    InputDecoration(labelText: t.registerRepeatPasswordLabel),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onRegister,
                  child: Text(t.registerButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
