import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SettingsSyncError {
  emailInvalid("Email is invalid."),
  emailNotFound("Email not found."),
  emailInUse("Email is already registered."),
  userDisabled("User is disabled."),
  wrongEmail("Email is wrong."),
  credentialIncorrect("Password wrong / email not found."),
  weakPassword("Password is too weak."),
  wrongPassword("Password is wrong."),
  disabled("Service disabled."),
  tokenExpired("Log in again."),
  networkError("Network error."),
  rateLimit("Try again later."),
  unknown("An unknown error occurred.");

  final String message;

  const SettingsSyncError(this.message);

  factory SettingsSyncError.fromFirebaseAuthException(
    FirebaseAuthException exception,
  ) => switch (exception.code) {
    'invalid-email' => emailInvalid,
    'user-not-found' => SettingsSyncError.emailNotFound,
    'email-already-in-use' => SettingsSyncError.emailInUse,
    'user-disabled' => SettingsSyncError.userDisabled,
    'invalid-credential' ||
    "INVALID_LOGIN_CREDENTIALS" => SettingsSyncError.credentialIncorrect,
    'weak-password' => SettingsSyncError.weakPassword,
    'wrong-password' => SettingsSyncError.wrongPassword,
    'user-mismatch' => SettingsSyncError.wrongEmail,
    'operation-not-allowed' => SettingsSyncError.disabled,
    'user-token-expired' => SettingsSyncError.tokenExpired,
    'network-request-failed' => SettingsSyncError.networkError,
    'too-many-requests' => SettingsSyncError.rateLimit,
    _ => unknown,
  };
}

class FirebaseErrorHandlerCubit extends Cubit<SettingsSyncError?> {
  FirebaseErrorHandlerCubit() : super(null);
  void setError([SettingsSyncError? error]) => emit(error);
}
