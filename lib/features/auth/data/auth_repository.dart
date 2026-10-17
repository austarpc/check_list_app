import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth? _firebaseAuthOverride;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuthOverride = firebaseAuth,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  FirebaseAuth get _firebaseAuth {
    if (_firebaseAuthOverride != null) return _firebaseAuthOverride;
    // Throws a descriptive StateError instead of Firebase core/no-app
    // if initialize() failed — prevents an obscure native crash.
    return FirebaseAuth.instance;
  }

  User? get currentUser {
    try {
      return _firebaseAuth.currentUser;
    } catch (_) {
      // Firebase not initialized (e.g. init failed on device,
      // or widget test with no Firebase) — treat as signed out.
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (_) {
      return Stream.value(null);
    }
  }

  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(credential.user!);
  }

  Future<UserModel> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(name);
    return _userFromFirebase(credential.user!);
  }

  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _userFromFirebase(userCredential.user!);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  UserModel _userFromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
