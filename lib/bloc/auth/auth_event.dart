abstract class AuthEvent {}

class AuthAppStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String displayName;
  final String email;
  final String password;

  AuthRegisterRequested({
    required this.displayName,
    required this.email,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {}
