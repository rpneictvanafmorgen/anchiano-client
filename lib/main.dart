import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/data/api_client.dart';
import 'package:anchiano_client/data/auth_repository.dart';
import 'package:anchiano_client/data/workspace_repository.dart';

import 'package:anchiano_client/data/realtime/realtime_service.dart';

import 'package:anchiano_client/bloc/auth/auth_bloc.dart';
import 'package:anchiano_client/bloc/auth/auth_event.dart';
import 'package:anchiano_client/bloc/auth/auth_state.dart';
import 'package:anchiano_client/bloc/workspace/workspace_bloc.dart';
import 'package:anchiano_client/bloc/workspace/workspace_event.dart';

import 'package:anchiano_client/ui/login_page.dart';
import 'package:anchiano_client/ui/workspace_list_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:anchiano_client/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<Locale?> currentLocale = ValueNotifier<Locale?>(null);
  final RealtimeService realtimeService = RealtimeService();

  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final WorkspaceRepository workspaceRepository;

  bool _realtimeConnected = false;
  void Function()? _unsubMyWorkspaces;

  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
  }

  @override
  void initState() {
    super.initState();

    apiClient = ApiClient(
      onUnauthorized: () async {
        // Interceptor wist JWT al. Wij zorgen hier dat de app state mee kantelt.
        if (!mounted) return;

        // Realtime uit (anders blijf je met een verlopen token "half connected")
        _disconnectRealtime();

        // Laat AuthBloc opnieuw checken -> gaat dan AuthUnauthenticated emitten
        context.read<AuthBloc>().add(AuthAppStarted());
      },
    );

    authRepository = AuthRepository(apiClient);
    workspaceRepository = WorkspaceRepository(apiClient);
  }

  Future<void> _connectRealtimeIfNeeded() async {
    if (_realtimeConnected && realtimeService.isConnected) return;

    final token = await authRepository.getToken();
    if (token == null || token.isEmpty) return;

    // Android emulator: http://10.0.2.2:8080
    // iOS simulator: http://localhost:8080
    // Device: http://<lan-ip>:8080
    const baseUrl = 'http://10.0.2.2:8080';

    realtimeService.connect(
      baseUrl: baseUrl,
      jwt: token,
      onConnected: () {
        _realtimeConnected = true;

        _unsubMyWorkspaces?.call();
        _unsubMyWorkspaces = realtimeService.subscribeMyWorkspaces(
          onEvent: (payload) {
            if (!mounted) return;
            context.read<WorkspaceBloc>().add(WorkspaceLoadRequested());
          },
        );
      },
      onError: (_) {
        _realtimeConnected = false;
      },
    );
  }

  void _disconnectRealtime() {
    _realtimeConnected = false;

    _unsubMyWorkspaces?.call();
    _unsubMyWorkspaces = null;

    realtimeService.disconnect();
  }

  @override
  void dispose() {
    currentLocale.dispose();
    _disconnectRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<WorkspaceRepository>.value(value: workspaceRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRepository)..add(AuthAppStarted()),
          ),
          BlocProvider(
            create: (_) => WorkspaceBloc(workspaceRepository),
          ),
        ],
        child: ValueListenableBuilder<Locale?>(
          valueListenable: currentLocale,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('nl'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    _connectRealtimeIfNeeded();
                  }

                  if (state is AuthUnauthenticated) {
                    _disconnectRealtime();
                  }
                },
                builder: (context, state) {
                  if (state is AuthChecking || state is AuthInitial) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is AuthAuthenticated) {
                    return WorkspaceListPage(
                      onChangeLanguage: changeLanguage,
                      realtimeService: realtimeService,
                    );
                  }

                  if (state is AuthUnauthenticated) {
                    return LoginPage(
                      error: state.error,
                      onChangeLanguage: changeLanguage,
                    );
                  }

                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
