import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/onboarding_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import '../Helpers/preference_helper.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    await PreferenceHelper.setFirstTime(false);

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<OnboardingViewModel>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    final onboardingItems = vm.getItems(lang);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _completeOnboarding(context),
            child: Text(
              AppStrings.get('skip', lang),
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: vm.pageController,
                  itemCount: onboardingItems.length,
                  onPageChanged: vm.onPageChanged,
                  itemBuilder: (context, index) {
                    final item = onboardingItems[index];

                    return AnimatedBuilder(
                      animation: vm.pageController,
                      builder: (context, child) {
                        double pageOffset = 0;

                        if (vm.pageController.hasClients &&
                            vm.pageController.positions.length == 1) {
                          pageOffset = (vm.pageController.page ?? 0) - index;
                        } else {
                          pageOffset = vm.currentIndex.toDouble() - index;
                        }

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height:
                                  MediaQuery.of(context).size.height * 0.55,
                                  width: double.infinity,
                                  color: isDarkMode
                                      ? Colors.black26
                                      : Colors.grey[100],
                                  child: Transform.translate(
                                    offset: Offset(-pageOffset * 40, 0),
                                    child: Image.asset(
                                      item.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Opacity(
                                opacity: (1 - pageOffset.abs()).clamp(0.0, 1.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: theme.textTheme.headlineLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: isDarkMode
                                            ? theme.colorScheme.secondary
                                            : theme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      item.subtitle,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                        theme.textTheme.bodyMedium?.color,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        onboardingItems.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: vm.currentIndex == i ? 24 : 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: vm.currentIndex == i
                                ? (isDarkMode
                                ? theme.colorScheme.secondary
                                : theme.primaryColor)
                                : (isDarkMode
                                ? Colors.white24
                                : Colors.black12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (vm.currentIndex == onboardingItems.length - 1) {
                          _completeOnboarding(context);
                        } else {
                          vm.nextPage(onboardingItems.length);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: vm.currentIndex == onboardingItems.length - 1
                            ? 150
                            : 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? theme.colorScheme.secondary
                              : theme.primaryColor,
                          borderRadius: BorderRadius.circular(
                            vm.currentIndex == onboardingItems.length - 1
                                ? 15
                                : 40,
                          ),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: vm.currentIndex == onboardingItems.length - 1
                                ? Text(
                              AppStrings.get('get_started', lang),
                              key: const ValueKey('text'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            )
                                : Image.asset(
                              'assets/images/button_next.png',
                              key: const ValueKey('icon'),
                              width: 35,
                              height: 35,
                              color: isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}