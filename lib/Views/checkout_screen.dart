import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../AppTheme/app_colors.dart';
import '../ViewModel/checkout_viewmodel.dart';
import '../ViewModel/cart_viewmodel.dart';
import '../ViewModel/settings_viewmodel.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVM = Provider.of<CartViewModel>(context);
    final String lang = Provider.of<SettingsViewModel>(context).appLocale.languageCode;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => CheckoutViewModel(),
      child: Consumer<CheckoutViewModel>(
        builder: (context, checkoutVM, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(lang == 'ar' ? "الدفع" : "Checkout"),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? "ملخص الطلب" : "Order Summary",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCard(cartVM, isDark, lang),
                  const Spacer(),
                  _buildPayButton(context, checkoutVM, cartVM, lang),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(CartViewModel cartVM, bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _rowItem(lang == 'ar' ? "المجموع" : "Subtotal", "\$${cartVM.totalPayment.toStringAsFixed(2)}", isDark),
          const Divider(height: 30),
          _rowItem(lang == 'ar' ? "الشحن" : "Shipping", lang == 'ar' ? "مجاني" : "Free", isDark, isGreen: true),
          const Divider(height: 30),
          _rowItem(lang == 'ar' ? "الإجمالي النهائي" : "Total", "\$${cartVM.totalPayment.toStringAsFixed(2)}", isDark, isGold: true, isBold: true),
        ],
      ),
    );
  }

  Widget _rowItem(String title, String value, bool isDark, {bool isGold = false, bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isBold ? 20 : 16,
          color: isGold ? AppColors.luxuryGold : (isGreen ? Colors.green : (isDark ? Colors.white : Colors.black)),
        )),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context, CheckoutViewModel checkoutVM, CartViewModel cartVM, String lang) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.luxuryGold,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: checkoutVM.isLoading
          ? null
          : () => checkoutVM.processPayment(
        context: context,
        totalAmount: cartVM.totalPayment,
        onClearCart: () => cartVM.clearCart(),
        languageCode: lang,
      ),
      child: checkoutVM.isLoading
          ? const CircularProgressIndicator(color: Colors.black)
          : Text(
        lang == 'ar' ? "تأكيد والدفع" : "Confirm & Pay",
        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}