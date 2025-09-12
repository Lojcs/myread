import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../core/state/error_handler.dart';
import '../../../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _firebaseService;

  static Future<void> init() async {
    await Firebase.initializeApp(
      name: "myread",
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseService = FirebaseService();
  }

  static FirebaseService get instance {
    return _firebaseService!;
  }

  late final FirebaseErrorHandlerCubit errorHandler =
      FirebaseErrorHandlerCubit();
  late final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  FirebaseService();
  Future<bool> catchFirebase(Future<void> Function() firebaseRequest) async {
    try {
      await firebaseRequest();
      return true;
    } on FirebaseAuthException catch (e) {
      errorHandler.setError(SettingsSyncError.fromFirebaseAuthException(e));
    }
    return false;
  }

  Future<bool> loginGate(Future<bool> Function() safeFunction) =>
      loggedIn ? safeFunction() : Future.value(false);

  Future<T?> loginGateCustom<T>(Future<T?> Function() safeFunction) =>
      loggedIn ? safeFunction() : Future.value(null);

  bool get loggedIn => _firebaseAuth.currentUser != null;

  Future<bool> createAccount(String email, String password) => catchFirebase(
    () => _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  Future<bool> logIn(String email, String password) => catchFirebase(
    () => _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  Future<bool> updatePassword(String password, String newPassword) => loginGate(
    () => catchFirebase(() async {
      final credential = EmailAuthProvider.credential(
        email: _firebaseAuth.currentUser!.email!,
        password: password,
      );
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
    }),
  );

  Future<bool> logOut() async => loginGate(() async {
    await _firebaseAuth.signOut();
    return true;
  });

  Future<bool> deleteAccount(String password) => loginGate(
    () => catchFirebase(() async {
      final credential = EmailAuthProvider.credential(
        email: _firebaseAuth.currentUser!.email!,
        password: password,
      );
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
      await _firebaseAuth.currentUser?.delete();
    }),
  );

  Future<void> setData(String data) => loginGate(() async {
    final uid = _firebaseAuth.currentUser!.uid;
    await _firebaseDatabase.ref("/users/$uid/datastring").set(data);
    return true;
  });

  Future<String?> getData() => loginGateCustom(() async {
    final uid = _firebaseAuth.currentUser!.uid;
    final data = await _firebaseDatabase.ref("/users/$uid/datastring").get();
    return data.value as String?;
  });
}
