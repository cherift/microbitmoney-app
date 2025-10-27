import 'package:flutter/material.dart';
import 'package:bit_money/services/localization_service.dart';

class AppLanguageController {
  static final AppLanguageController _instance = AppLanguageController._internal();
  factory AppLanguageController() => _instance;
  AppLanguageController._internal();

  Function(Locale)? _updateLocaleCallback;

  void setUpdateCallback(Function(Locale) callback) {
    _updateLocaleCallback = callback;
  }

  Future<void> changeLanguage(String languageCode) async {
    await LocalizationService.setLocale(languageCode);

    final locale = LocalizationService.supportedLocales[languageCode]!;
    if (_updateLocaleCallback != null) {
      _updateLocaleCallback!(locale);
    }
  }
}