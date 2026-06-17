import 'package:flutter/material.dart';

ValueNotifier<bool> isDark = ValueNotifier(false);
ValueNotifier<String?> isId = ValueNotifier("");
ValueNotifier<String?> isUser = ValueNotifier("");


// This holds the current language. Default is English.
ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

void updateLanguage(String code) {
  appLocale.value = Locale(code);
}