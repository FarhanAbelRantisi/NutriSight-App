import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  bool isUploadingImage = false;
  bool isChangingEmail = false;
  bool isChangingPassword = false;

  User? get currentUser => _repository.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get userDocStream {
    final user = _repository.currentUser;
    if (user == null) return null;
    return _repository.userDocStream(user.uid);
  }

  Future<String?> uploadProfileImage(XFile picked) async {
    if (isUploadingImage) return null;
    isUploadingImage = true;
    notifyListeners();

    try {
      await _repository.updateProfileImage(picked);
      return null; // null = sukses
    } catch (e) {
      return e.toString();
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<String?> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    if (isChangingEmail) return null;
    isChangingEmail = true;
    notifyListeners();

    try {
      await _repository.changeEmail(
        currentPassword: currentPassword,
        newEmail: newEmail,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isChangingEmail = false;
      notifyListeners();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isChangingPassword) return null;
    isChangingPassword = true;
    notifyListeners();

    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isChangingPassword = false;
      notifyListeners();
    }
  }
}
