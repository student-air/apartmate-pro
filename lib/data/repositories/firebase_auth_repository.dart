// lib/data/repositories/firebase_auth_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apartmate/data/models/user_model.dart';
import 'package:apartmate/domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  UserModel? _cached;
  bool _googleInitialized = false;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(
      serverClientId:
          '308746297398-jpobogk3cmajv09lvmq13rmdoemhdln0.apps.googleusercontent.com',
    );
    _googleInitialized = true;
  }

  Future<UserModel> _loadOrCreateProfile(User user, {UserModel? seed}) async {
    final ref = _userDoc(user.uid);
    final snap = await ref.get();

    if (snap.exists && snap.data() != null) {
      final map = snap.data()!;
      final model = UserModel(
        id: user.uid,
        fullName: map['fullName'] as String? ?? user.displayName ?? '',
        email: map['email'] as String? ?? user.email ?? '',
        phone: map['phone'] as String? ?? '',
        role: map['role'] as String? ?? 'Society Owner',
        photoPath: map['photoPath'] as String? ?? user.photoURL,
      );
      _cached = model;
      return model;
    }

    final model = seed ??
        UserModel(
          id: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phone: '',
          role: 'Society Owner',
          photoPath: user.photoURL,
        );

    await ref.set({
      'fullName': model.fullName,
      'email': model.email,
      'phone': model.phone,
      'role': model.role,
      'photoPath': model.photoPath,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _cached = model;
    return model;
  }

  @override
  UserModel? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _cached ?? _map(u);
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: username.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user returned from Firebase',
      );
    }
    return _loadOrCreateProfile(user);
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user returned from Firebase',
      );
    }

    await user.updateDisplayName(fullName.trim());
    await user.reload();

    final model = UserModel(
      id: user.uid,
      fullName: fullName.trim(),
      email: user.email ?? email.trim(),
      phone: phone.trim(),
      role: 'Society Owner',
    );

    await _userDoc(user.uid).set({
      'fullName': model.fullName,
      'email': model.email,
      'phone': model.phone,
      'role': model.role,
      'photoPath': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _cached = model;
    return model;
  }

  @override
  Future<UserModel> updateProfile(UserModel updated) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    await user.updateDisplayName(updated.fullName);
    await user.reload();

    await _userDoc(user.uid).set({
      'fullName': updated.fullName,
      'email': updated.email,
      'phone': updated.phone,
      'role': updated.role,
      'photoPath': updated.photoPath,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _cached = UserModel(
      id: user.uid,
      fullName: updated.fullName,
      email: updated.email,
      phone: updated.phone,
      role: updated.role,
      photoPath: updated.photoPath,
    );
    return _cached!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Email is required',
      );
    }
    await _auth.sendPasswordResetEmail(email: trimmed);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Not signed in');
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> logout() async {
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    _cached = null;
  }

  @override
  Future<({UserModel user, bool isNewUser})> loginWithGoogle() async {
    await _ensureGoogleInitialized();

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code.name.contains('canceled') ||
          e.code.name.contains('cancelled') ||
          e.code.name.contains('interrupted')) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Google sign-in was cancelled',
        );
      }
      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google sign-in did not return an ID token',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user returned from Google sign-in',
      );
    }

    final isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;
    final model = await _loadOrCreateProfile(user);
    return (user: model, isNewUser: isNewUser);
  }

  @override
  Future<UserModel> loginWithApple() async {
    throw UnimplementedError('Apple sign-in will be added later');
  }

  UserModel _map(User user) {
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? _cached?.phone ?? '',
      role: 'Society Owner',
      photoPath: user.photoURL,
    );
  }
}