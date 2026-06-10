part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String displayName;
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
  });
  @override
  List<Object> get props => [email, password, username, displayName];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
