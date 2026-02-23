import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../AppTheme/app_colors.dart';

class CheckoutViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> processPayment({
    required BuildContext context,
    required double totalAmount,
    required VoidCallback onClearCart,
    required String languageCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();
      final secretKey = remoteConfig.getString('stripe_secret_key');

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (totalAmount * 100).toInt().toString(),
          'currency': 'usd',
        },
      );

      final paymentData = jsonDecode(response.body);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentData['client_secret'],
          merchantDisplayName: 'Rika Store',
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColors.luxuryGold,
              background: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      onClearCart();

      if (context.mounted) {
        _showSuccessDialog(context, languageCode);
      }
    } on StripeException catch (e) {
      debugPrint("❌ Stripe Error: ${e.error.localizedMessage}");
    } catch (e) {
      debugPrint("❌ Payment Process Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showSuccessDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          lang == 'ar' ? "تمت عملية الدفع بنجاح!" : "Payment Successful!",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            child: Center(
              child: Text(
                lang == 'ar' ? "العودة للرئيسية" : "Back to Home",
                style: const TextStyle(
                  color: AppColors.luxuryGold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
