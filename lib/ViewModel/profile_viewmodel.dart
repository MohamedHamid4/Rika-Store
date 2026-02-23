import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/Helpers/preference_helper.dart';
import 'package:rika_store/Model/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get imagePath => _auth.currentUser?.photoURL ?? "";

  UserModel get user {
    final firebaseUser = _auth.currentUser;
    return UserModel(
      name: firebaseUser?.displayName ?? PreferenceHelper.getUserName(),
      email: firebaseUser?.email ?? PreferenceHelper.getUserEmail(),
      profileImage: firebaseUser?.photoURL ?? 'assets/images/user-male.png',
    );
  }

  List<Map<String, dynamic>> getProfileOptions(String lang) {
    return [
      {
        "title": AppStrings.get('my_orders', lang),
        "icon": Icons.shopping_bag_outlined,
        "route": "/orders",
      },
      {
        "title": AppStrings.get('personal_details', lang),
        "icon": Icons.person_outline,
        "route": "/personal_details",
      },
      {
        "title": AppStrings.get('shipping_address', lang),
        "icon": Icons.location_on_outlined,
        "route": "/address",
      },
      {
        "title": AppStrings.get('settings', lang),
        "icon": Icons.settings_outlined,
        "route": "/settings",
      },
    ];
  }

  Future<void> updateUserName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName);

      await PreferenceHelper.saveUserData(name: newName);

      notifyListeners();
    } catch (e) {
      debugPrint("خطأ في تحديث الاسم: $e");
    }
  }
}
