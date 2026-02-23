import 'package:flutter/material.dart';

class AppLocale {
  static String translate(BuildContext context, String en, String ar) {
    return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  }
}