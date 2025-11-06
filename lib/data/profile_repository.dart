import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfileImage(XFile picked) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final file = File(picked.path);

    final ref = _storage
        .ref()
        .child('user_profiles')
        .child('${user.uid}.jpg');

    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('users').doc(user.uid).set(
      {
        'photoUrl': downloadUrl,
        'email': user.email,
      },
      SetOptions(merge: true),
    );

    await user.updatePhotoURL(downloadUrl);
  }

  Future<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("User not logged in");
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword.trim(),
    );

    await user.reauthenticateWithCredential(cred);
    await user.verifyBeforeUpdateEmail(newEmail.trim());

    await _firestore.collection('users').doc(user.uid).set(
      {
        'email': newEmail.trim(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("User not logged in");
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword.trim(),
    );

    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword.trim());
  }
}