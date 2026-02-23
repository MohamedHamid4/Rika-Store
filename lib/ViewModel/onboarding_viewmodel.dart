import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/Model/onboarding_model.dart';

class OnboardingViewModel extends ChangeNotifier {
  final PageController pageController = PageController();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<OnboardingItem> getItems(String lang) {
    return [
      OnboardingItem(
        image: 'assets/images/on1.png',
        title: AppStrings.get('onboarding_title_1', lang),
        subtitle: AppStrings.get('onboarding_subtitle_1', lang),
      ),
      OnboardingItem(
        image: 'assets/images/on2.png',
        title: AppStrings.get('onboarding_title_2', lang),
        subtitle: AppStrings.get('onboarding_subtitle_2', lang),
      ),
      OnboardingItem(
        image: 'assets/images/on3.png',
        title: AppStrings.get('onboarding_title_3', lang),
        subtitle: AppStrings.get('onboarding_subtitle_3', lang),
      ),
    ];
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextPage(int itemsLength) {
    if (_currentIndex < itemsLength - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}