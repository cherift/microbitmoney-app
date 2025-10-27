import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  LocalizationService._();

  static const String languageKey = 'selected_language';
  static const Locale frLocale = Locale('fr', 'FR');
  static const Locale enLocale = Locale('en', 'GB');

  static const Map<String, Locale> supportedLocales = <String, Locale>{
    'fr': frLocale,
    'en': enLocale,
  };

  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
  };

  static Future<Locale> getStoredOrSystemLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString(languageKey);

    if (storedCode != null && supportedLocales.containsKey(storedCode)) {
      return supportedLocales[storedCode]!;
    }

    return getDeviceLocale();
  }

  static Locale getDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final languageCode = deviceLocale.languageCode.toLowerCase();

    for (final locale in supportedLocales.values) {
      if (locale.languageCode == languageCode &&
          locale.countryCode == deviceLocale.countryCode) {
        return locale;
      }
    }

    return supportedLocales[languageCode] ?? enLocale;
  }

  static Future<bool> setLocale(String languageCode) async {
    if (!supportedLocales.containsKey(languageCode)) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(languageKey, languageCode);
  }

  static String getLanguageName(String languageCode) =>
      languageNames[languageCode] ?? 'Français';

  static Future<String> getCurrentLanguageCode() async {
    final locale = await getStoredOrSystemLocale();
    return locale.languageCode;
  }
}
