// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bit Money';

  @override
  String get login => 'Log In';

  @override
  String get profile => 'Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get accountType => 'Account Type';

  @override
  String get commission => 'Commission';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get loading => 'Loading...';

  @override
  String get administrator => 'Administrator';

  @override
  String get pointOfSale => 'Point Of Sale';

  @override
  String get pdv => 'POS';

  @override
  String get pdvName => 'POS Name';

  @override
  String get address => 'Address';

  @override
  String get times => 'Schedule';

  @override
  String get openOnWeekends => 'Open on weekends ?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get updateProfile => 'Update profile';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get optional => 'Optional';

  @override
  String get newPassword => 'New password';

  @override
  String get enterAFirstName => 'Please enter your first name';

  @override
  String get enterALastName => 'Please enter your last name';

  @override
  String get passwordRegex => 'Password must contain at least 6 characters';

  @override
  String get passwordNotConfirmed => 'Passwords do not match';

  @override
  String get profileUpdated => 'Profile successfully updated';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get pleaseLogin => 'Log in to access your account';

  @override
  String get emailOrPhone => 'Email or Phone';

  @override
  String get enterYourPassword => 'Please enter your password';

  @override
  String get enterYourPasswordError => 'Please enter your password';

  @override
  String get enterEmailOrPhoneError =>
      'Please enter your email or phone number';

  @override
  String get emailOrPhoneInvalid => 'Invalid email or phone format';

  @override
  String get errorOccured => 'An error has occurred. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get invalidCredentials => 'Invalid Credentials';

  @override
  String get hello => 'Hello';

  @override
  String get welcome => 'Welcome to your dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get total => 'Total';

  @override
  String get thisWeek => 'this week';

  @override
  String get thisMonth => 'this month';

  @override
  String get currency => 'GNF';

  @override
  String get send => 'Send';

  @override
  String get receive => 'Receive';

  @override
  String get enroll => 'Enroll';

  @override
  String get ourPdv => 'Our Stores';

  @override
  String get quote => 'Quotes';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get ourPdvs => 'Our Points of Sale';

  @override
  String get searchPdv => 'Search for a store';

  @override
  String get filters => 'Filters';

  @override
  String get openPdvs => 'Open stores only';

  @override
  String pdvsFound(int count, String plural) {
    return '$count store$plural found';
  }

  @override
  String lastUpdate(String time) {
    return 'Last update: $time';
  }

  @override
  String get noPdvFound => 'No stores found';

  @override
  String get tryModifySearch => 'Try modifying your search criteria';

  @override
  String get noAddressSpecified => 'No address specified';

  @override
  String get hours => 'Hours';

  @override
  String get weekend => 'Weekend';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get close => 'Close';

  @override
  String loadPdvsError(String error) {
    return 'Unable to load stores: $error';
  }
}
