import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/settings_sync_cubit.dart';

class FirebaseService {
  final SettingsSyncCubit? syncCubit;

  FirebaseService({this.syncCubit});
  Future<bool> catchFirebase(Future<void> Function() firebaseRequest) async {
    try {
      await firebaseRequest();
      return true;
    } on FirebaseAuthException catch (e) {
      syncCubit?.setError(SettingsSyncError.fromFirebaseAuthException(e));
    }
    return false;
  }

  Future<bool> createAccount(String email, String password) async =>
      catchFirebase(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

  Future<bool> logIn(String email, String password) async => catchFirebase(
    () => FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  Future<bool> updatePassword(String password, String newPassword) async =>
      catchFirebase(() async {
        final credential = EmailAuthProvider.credential(
          email: FirebaseAuth.instance.currentUser!.email!,
          password: password,
        );
        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
          credential,
        );
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      });

  Future<bool> logOut() async {
    await FirebaseAuth.instance.signOut();
    return true;
  }

  Future<bool> deleteAccount(String password) async => catchFirebase(() async {
    final credential = EmailAuthProvider.credential(
      email: FirebaseAuth.instance.currentUser!.email!,
      password: password,
    );
    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
      credential,
    );
    await FirebaseAuth.instance.currentUser?.delete();
  });
}
