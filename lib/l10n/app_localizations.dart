import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bit Money'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @pointOfSale.
  ///
  /// In en, this message translates to:
  /// **'Point Of Sale'**
  String get pointOfSale;

  /// No description provided for @pdv.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pdv;

  /// No description provided for @pdvName.
  ///
  /// In en, this message translates to:
  /// **'POS Name'**
  String get pdvName;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get times;

  /// No description provided for @openOnWeekends.
  ///
  /// In en, this message translates to:
  /// **'Open on weekends ?'**
  String get openOnWeekends;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @enterAFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get enterAFirstName;

  /// No description provided for @enterALastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get enterALastName;

  /// No description provided for @passwordRegex.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters'**
  String get passwordRegex;

  /// No description provided for @passwordNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotConfirmed;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in to access your account'**
  String get pleaseLogin;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterYourPassword;

  /// No description provided for @enterYourPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterYourPasswordError;

  /// No description provided for @enterEmailOrPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number'**
  String get enterEmailOrPhoneError;

  /// No description provided for @emailOrPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or phone format'**
  String get emailOrPhoneInvalid;

  /// No description provided for @errorOccured.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred. Please try again.'**
  String get errorOccured;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid Credentials'**
  String get invalidCredentials;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your dashboard'**
  String get welcome;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonth;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'GNF'**
  String get currency;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @enroll.
  ///
  /// In en, this message translates to:
  /// **'Enroll'**
  String get enroll;

  /// No description provided for @ourPdv.
  ///
  /// In en, this message translates to:
  /// **'Our Stores'**
  String get ourPdv;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quote;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @ourPdvs.
  ///
  /// In en, this message translates to:
  /// **'Our Points of Sale'**
  String get ourPdvs;

  /// No description provided for @searchPdv.
  ///
  /// In en, this message translates to:
  /// **'Search for a store'**
  String get searchPdv;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @openPdvs.
  ///
  /// In en, this message translates to:
  /// **'Open stores only'**
  String get openPdvs;

  /// No description provided for @pdvsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} store{plural} found'**
  String pdvsFound(int count, String plural);

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update: {time}'**
  String lastUpdate(String time);

  /// No description provided for @noPdvFound.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get noPdvFound;

  /// No description provided for @tryModifySearch.
  ///
  /// In en, this message translates to:
  /// **'Try modifying your search criteria'**
  String get tryModifySearch;

  /// No description provided for @noAddressSpecified.
  ///
  /// In en, this message translates to:
  /// **'No address specified'**
  String get noAddressSpecified;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @weekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get weekend;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loadPdvsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load stores: {error}'**
  String loadPdvsError(String error);

  /// No description provided for @quotesList.
  ///
  /// In en, this message translates to:
  /// **'Quotes List'**
  String get quotesList;

  /// No description provided for @quoteNumber.
  ///
  /// In en, this message translates to:
  /// **'Quote #{id}'**
  String quoteNumber(String id);

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount'**
  String get amountHint;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get enterAmount;

  /// No description provided for @amountToSend.
  ///
  /// In en, this message translates to:
  /// **'Amount to Send'**
  String get amountToSend;

  /// No description provided for @amountToReceive.
  ///
  /// In en, this message translates to:
  /// **'Amount to Receive'**
  String get amountToReceive;

  /// No description provided for @notDefined.
  ///
  /// In en, this message translates to:
  /// **'Not defined'**
  String get notDefined;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @recipientCountry.
  ///
  /// In en, this message translates to:
  /// **'Recipient Country'**
  String get recipientCountry;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @noQuoteAvailable.
  ///
  /// In en, this message translates to:
  /// **'No quotes available'**
  String get noQuoteAvailable;

  /// No description provided for @createNewQuote.
  ///
  /// In en, this message translates to:
  /// **'Create a new quote by pressing the + button'**
  String get createNewQuote;

  /// No description provided for @quotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Quotes'**
  String quotesCount(int count);

  /// No description provided for @loadQuotesError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load quotes: {error}'**
  String loadQuotesError(String error);

  /// No description provided for @newQuote.
  ///
  /// In en, this message translates to:
  /// **'New Quote'**
  String get newQuote;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search for a country'**
  String get searchCountry;

  /// No description provided for @enterAmountToSend.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to send'**
  String get enterAmountToSend;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @enterAmountToReceive.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to receive'**
  String get enterAmountToReceive;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request Quote'**
  String get requestQuote;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @selectOperator.
  ///
  /// In en, this message translates to:
  /// **'Please select an operator'**
  String get selectOperator;

  /// No description provided for @operatorChoice.
  ///
  /// In en, this message translates to:
  /// **'Select an operator'**
  String get operatorChoice;

  /// No description provided for @selectRecipientCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a recipient country'**
  String get selectRecipientCountry;

  /// No description provided for @enterOnlyOneAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter only one amount (either send OR receive)'**
  String get enterOnlyOneAmount;

  /// No description provided for @minimumAmount.
  ///
  /// In en, this message translates to:
  /// **'The minimum amount is {amount} GNF'**
  String minimumAmount(String amount);

  /// No description provided for @maximumAmount.
  ///
  /// In en, this message translates to:
  /// **'The maximum amount is {amount} GNF'**
  String maximumAmount(String amount);

  /// No description provided for @quoteRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Quote request sent successfully'**
  String get quoteRequestSuccess;

  /// No description provided for @quoteCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating quote: {error}'**
  String quoteCreationError(String error);

  /// No description provided for @operatorsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load operators'**
  String get operatorsLoadError;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountGreaterThanZero;

  /// No description provided for @newPdv.
  ///
  /// In en, this message translates to:
  /// **'New Store Location'**
  String get newPdv;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get emailHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+224 000000000'**
  String get phoneHint;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @pdvInformation.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get pdvInformation;

  /// No description provided for @pdvNameHint.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get pdvNameHint;

  /// No description provided for @commissionHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get commissionHint;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get addressHint;

  /// No description provided for @openingTime.
  ///
  /// In en, this message translates to:
  /// **'Opening Time'**
  String get openingTime;

  /// No description provided for @closingTime.
  ///
  /// In en, this message translates to:
  /// **'Closing Time'**
  String get closingTime;

  /// No description provided for @openWeekend.
  ///
  /// In en, this message translates to:
  /// **'Open on weekends'**
  String get openWeekend;

  /// No description provided for @createPdv.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get createPdv;

  /// No description provided for @enrollmentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Enrollment Confirmation'**
  String get enrollmentConfirmation;

  /// No description provided for @pdvCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The new store \'{name}\' has been successfully created.'**
  String pdvCreatedSuccess(String name);

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterPdvName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a store name'**
  String get enterPdvName;

  /// No description provided for @enterPercentage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a percentage'**
  String get enterPercentage;

  /// No description provided for @commissionRange.
  ///
  /// In en, this message translates to:
  /// **'Commission must be between 0 and 100'**
  String get commissionRange;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get enterAddress;

  /// No description provided for @transactionList.
  ///
  /// In en, this message translates to:
  /// **'Transfers List'**
  String get transactionList;

  /// No description provided for @totalTransactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Transfers Amount'**
  String get totalTransactionAmount;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transfers'**
  String get noTransactions;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceipt;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @transactionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Transaction Receipt'**
  String get transactionReceipt;

  /// No description provided for @receivedDate.
  ///
  /// In en, this message translates to:
  /// **'Reception Date'**
  String get receivedDate;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @transactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Transaction Number'**
  String get transactionNumber;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumber;

  /// No description provided for @transferReason.
  ///
  /// In en, this message translates to:
  /// **'Transfer Reason'**
  String get transferReason;

  /// No description provided for @familyAssistance.
  ///
  /// In en, this message translates to:
  /// **'Family assistance'**
  String get familyAssistance;

  /// No description provided for @beneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get beneficiary;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @transferDetails.
  ///
  /// In en, this message translates to:
  /// **'Transfer Details'**
  String get transferDetails;

  /// No description provided for @amountSent.
  ///
  /// In en, this message translates to:
  /// **'Amount Sent'**
  String get amountSent;

  /// No description provided for @totalAmountIncludesTax.
  ///
  /// In en, this message translates to:
  /// **'Total Amount (incl. tax)'**
  String get totalAmountIncludesTax;

  /// No description provided for @receptionList.
  ///
  /// In en, this message translates to:
  /// **'Received Transfers'**
  String get receptionList;

  /// No description provided for @totalReceptionAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Received Amount'**
  String get totalReceptionAmount;

  /// No description provided for @noReceptions.
  ///
  /// In en, this message translates to:
  /// **'No received transfers'**
  String get noReceptions;

  /// No description provided for @receptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Reception Details'**
  String get receptionDetails;

  /// No description provided for @receptionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reception Receipt'**
  String get receptionReceipt;

  /// No description provided for @amountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount Received'**
  String get amountReceived;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @viewReceptionDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewReceptionDetails;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get nextStep;

  /// No description provided for @sendTransfer.
  ///
  /// In en, this message translates to:
  /// **'Send Transfer'**
  String get sendTransfer;

  /// No description provided for @senderInformation.
  ///
  /// In en, this message translates to:
  /// **'Sender Information'**
  String get senderInformation;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get idType;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @birthPlace.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get birthPlace;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @searchNationality.
  ///
  /// In en, this message translates to:
  /// **'Search for a nationality'**
  String get searchNationality;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a birth date'**
  String get selectBirthDate;

  /// No description provided for @selectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Please select an expiry date'**
  String get selectExpiryDate;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @senderInfoError.
  ///
  /// In en, this message translates to:
  /// **'Error sending information'**
  String get senderInfoError;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @identityCard.
  ///
  /// In en, this message translates to:
  /// **'Identity Card'**
  String get identityCard;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @recipientInformation.
  ///
  /// In en, this message translates to:
  /// **'Recipient Information'**
  String get recipientInformation;

  /// No description provided for @recipientInfoError.
  ///
  /// In en, this message translates to:
  /// **'Error when sending recipient information'**
  String get recipientInfoError;

  /// No description provided for @billPayment.
  ///
  /// In en, this message translates to:
  /// **'Bill payment'**
  String get billPayment;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @confirmationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during confirmation'**
  String get confirmationError;

  /// No description provided for @errorOccurredWithDetails.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {details}'**
  String errorOccurredWithDetails(String details);

  /// No description provided for @transferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Transfer confirmation'**
  String get transferConfirmation;

  /// No description provided for @transferProcessingMessage.
  ///
  /// In en, this message translates to:
  /// **'The transfer request is being processed.'**
  String get transferProcessingMessage;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference: {id}'**
  String referenceLabel(String id);

  /// No description provided for @receiptAvailabilityMessage.
  ///
  /// In en, this message translates to:
  /// **'You can find the receipt in the transaction history at any time.'**
  String get receiptAvailabilityMessage;

  /// No description provided for @confirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmationTitle;

  /// No description provided for @verifyInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Verify your information)'**
  String get verifyInformationSubtitle;

  /// No description provided for @incompleteSenderInfo.
  ///
  /// In en, this message translates to:
  /// **'Incomplete sender information'**
  String get incompleteSenderInfo;

  /// No description provided for @incompleteRecipientInfo.
  ///
  /// In en, this message translates to:
  /// **'Incomplete recipient information'**
  String get incompleteRecipientInfo;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
