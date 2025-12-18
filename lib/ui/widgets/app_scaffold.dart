import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';
import 'package:anchiano_client/bloc/auth/auth_bloc.dart';
import 'package:anchiano_client/bloc/auth/auth_event.dart';

import 'language_switcher.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showLogout;
  final Widget? floatingActionButton;
  final void Function(Locale locale) onChangeLanguage;

  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.onChangeLanguage,
    this.showLogout = false,
    this.floatingActionButton,
    this.actions,
  });

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (actions != null) ...actions!,
          LanguageSwitcher(onChangeLanguage: onChangeLanguage),
          if (showLogout)
            IconButton(
              tooltip: t.logout,
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
