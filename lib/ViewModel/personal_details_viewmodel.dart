import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/preference_helper.dart';

class PersonalDetailsViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userName =>
      _auth.currentUser?.displayName ?? PreferenceHelper.getUserName();

  String get email => _auth.currentUser?.email ?? "";

  String get age => PreferenceHelper.getUserAge().toString();

  String get imagePath => PreferenceHelper.getUserImage();

  String get genderKey => "Male";

  Future<void> updateUserInfo({
    required String name,
    required String newEmail,
    required String newGenderKey,
    required String newAge,
    String? newImagePath,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        if (name != user.displayName) {
          await user.updateDisplayName(name);
        }

        if (newEmail != user.email && newEmail.isNotEmpty) {
          await user.verifyBeforeUpdateEmail(newEmail);
        }

        int ageInt = int.tryParse(newAge) ?? 0;
        await PreferenceHelper.saveUserData(
          name: name,
          age: ageInt,
          image: newImagePath ?? imagePath,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint("خطأ أثناء التحديث: $e");
      rethrow;
    }
  }
}
