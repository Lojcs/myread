import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/cubit/issues_cubit.dart';
import '../service/firebase_service.dart';
import 'settings_cubit.dart';

class SettingsSyncState extends Equatable {
  final User? user;
  final bool autoSync;

  final bool signedIn;

  const SettingsSyncState({this.user, required this.autoSync})
    : signedIn = user != null;

  SettingsSyncState withAutoSync(bool value) =>
      SettingsSyncState(user: user, autoSync: value);
  @override
  List<Object?> get props => [user, autoSync];
}

class SettingsSyncCubit extends Cubit<SettingsSyncState> {
  final SettingsCubit _settingsCubit;
  final ComicIssuesCubit _issuesCubit;
  late final StreamSubscription<User?> firebaseListener;
  late final StreamSubscription<SettingsState> settingsListener;

  SettingsSyncCubit(this._settingsCubit, this._issuesCubit)
    : super(SettingsSyncState(autoSync: _settingsCubit.state.autoSync)) {
    firebaseListener = FirebaseAuth.instance.authStateChanges().listen(
      (user) => emit(SettingsSyncState(user: user, autoSync: state.autoSync)),
    );
    settingsListener = _settingsCubit.stream.listen((settingsState) {
      if (settingsState.autoSync != state.autoSync) {
        emit(state.withAutoSync(settingsState.autoSync));
      }
    });
  }
  @override
  Future<void> close() {
    firebaseListener.cancel();
    settingsListener.cancel();
    return super.close();
  }

  late final FirebaseService firebase = FirebaseService.instance;

  Future<bool> createAccount(String email, String password) =>
      firebase.createAccount(email, password);

  Future<bool> logIn(String email, String password) =>
      firebase.logIn(email, password);

  Future<bool> updatePassword(String password, String newPassword) =>
      firebase.updatePassword(password, newPassword);

  Future<bool> logOut() => firebase.logOut();
  Future<bool> deleteAccount(String password) =>
      firebase.deleteAccount(password);

  void setAutoSync([bool? value]) =>
      _settingsCubit.setAutoSync(value ?? !state.autoSync);

  Future<void> saveData() => _issuesCubit.saveData();
  Future<void> fetchData() => _issuesCubit.fetchData();
}
