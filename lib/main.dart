import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Helpers/firebase_options.dart';
import 'package:rika_store/AppTheme/app_theme.dart';
import 'package:rika_store/Helpers/preference_helper.dart';
import 'package:rika_store/ViewModel/favorites_viewmodel.dart';
import 'package:rika_store/ViewModel/cart_viewmodel.dart';
import 'package:rika_store/ViewModel/categories_viewmodel.dart';
import 'package:rika_store/ViewModel/login_viewmodel.dart';
import 'package:rika_store/ViewModel/navigation_viewmodel.dart';
import 'package:rika_store/ViewModel/notification_viewmodel.dart';
import 'package:rika_store/ViewModel/personal_details_viewmodel.dart';
import 'package:rika_store/ViewModel/product_categories_viewmodel.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import 'package:rika_store/ViewModel/onboarding_viewmodel.dart';
import 'package:rika_store/ViewModel/signup_viewmodel.dart';
import 'package:rika_store/ViewModel/home_viewmodel.dart';
import 'package:rika_store/ViewModel/product_details_viewmodel.dart';
import 'package:rika_store/ViewModel/checkout_viewmodel.dart';
import 'package:rika_store/Views/cart_screen.dart';
import 'package:rika_store/Views/categories_screen.dart';
import 'package:rika_store/Views/login_screen.dart';
import 'package:rika_store/Views/navigation_bar_screen.dart';
import 'package:rika_store/Views/notification_screen.dart';
import 'package:rika_store/Views/onboarding_screen.dart';
import 'package:rika_store/Views/product_categories_screen.dart';
import 'package:rika_store/Views/product_details_screen.dart';
import 'package:rika_store/Views/profile_screen.dart';
import 'package:rika_store/Views/signup_screen.dart';
import 'package:rika_store/Views/splash_screen.dart';
import 'package:rika_store/Views/success_screen.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ),
  );

  try {
    await remoteConfig.fetchAndActivate();
    Stripe.publishableKey = remoteConfig.getString('stripe_publishable_key');
    if (Stripe.publishableKey.isEmpty) {
      Stripe.publishableKey = "pk_test_your_fallback_key_here";
    }
  } catch (e) {
    debugPrint("Remote Config Error: $e");
  }

  await PreferenceHelper.init();
  final bool isFirstTime = PreferenceHelper.isFirstTime() ?? true;
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  String initialRoute;
  if (isFirstTime) {
    initialRoute = '/onboarding';
  } else if (isLoggedIn) {
    initialRoute = '/home';
  } else {
    initialRoute = '/login';
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => CategoriesViewModel()),
        ChangeNotifierProvider(create: (_) => ProductCategoriesViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => PersonalDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
      ],
      child: MyApp(startRoute: initialRoute),
    ),
  );
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MyApp extends StatefulWidget {
  final String startRoute;

  const MyApp({super.key, required this.startRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked! Path: /notification');
      // الانتقال المباشر لصفحة الإشعارات عند النقر
      Navigator.of(context).pushNamed('/notification');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsVM, child) {
        return MaterialApp(
          locale: settingsVM.appLocale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scrollBehavior: NoGlowBehavior(),
          debugShowCheckedModeBanner: false,
          title: 'Rika Store',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsVM.themeMode,
          initialRoute: widget.startRoute,
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/successful': (context) => const SuccessScreen(),
            '/home': (context) => const NavigationBarScreen(),
            '/categories': (context) => const CategoriesScreen(),
            '/product_categories': (context) => const ProductCategoriesScreen(),
            '/product_details': (context) => const ProductDetailsScreen(),
            '/cart': (context) => const CartScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/notification': (context) => const NotificationScreen(),
          },
        );
      },
    );
  }
}