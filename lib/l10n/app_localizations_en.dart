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
  String get commission => 'Commission';

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

  @override
  String get quotesList => 'Quotes List';

  @override
  String quoteNumber(String id) {
    return 'Quote #$id';
  }

  @override
  String get amount => 'Amount';

  @override
  String get amountHint => 'Enter the amount';

  @override
  String get enterAmount => 'Please enter an amount';

  @override
  String get amountToSend => 'Amount to Send';

  @override
  String get amountToReceive => 'Amount to Receive';

  @override
  String get notDefined => 'Not defined';

  @override
  String get fees => 'Fees';

  @override
  String get recipientCountry => 'Recipient Country';

  @override
  String get operator => 'Operator';

  @override
  String get noQuoteAvailable => 'No quotes available';

  @override
  String get createNewQuote => 'Create a new quote by pressing the + button';

  @override
  String quotesCount(int count) {
    return '$count Quotes';
  }

  @override
  String loadQuotesError(String error) {
    return 'Unable to load quotes: $error';
  }

  @override
  String get newQuote => 'New Quote';

  @override
  String get searchCountry => 'Search for a country';

  @override
  String get enterAmountToSend => 'Enter amount to send';

  @override
  String get or => 'OR';

  @override
  String get enterAmountToReceive => 'Enter amount to receive';

  @override
  String get requestQuote => 'Request Quote';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get selectOperator => 'Please select an operator';

  @override
  String get operatorChoice => 'Select an operator';

  @override
  String get selectRecipientCountry => 'Please select a recipient country';

  @override
  String get enterOnlyOneAmount =>
      'Please enter only one amount (either send OR receive)';

  @override
  String minimumAmount(String amount) {
    return 'The minimum amount is $amount GNF';
  }

  @override
  String maximumAmount(String amount) {
    return 'The maximum amount is $amount GNF';
  }

  @override
  String get quoteRequestSuccess => 'Quote request sent successfully';

  @override
  String quoteCreationError(String error) {
    return 'Error creating quote: $error';
  }

  @override
  String get operatorsLoadError => 'Unable to load operators';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get amountGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get newPdv => 'New Store Location';

  @override
  String get userInformation => 'User Information';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get phoneHint => '+224 000000000';

  @override
  String get firstNameHint => 'First Name';

  @override
  String get lastNameHint => 'Last Name';

  @override
  String get passwordHint => '••••••••';

  @override
  String get pdvInformation => 'Store Information';

  @override
  String get pdvNameHint => 'Store name';

  @override
  String get commissionHint => '0';

  @override
  String get addressHint => 'Full address';

  @override
  String get openingTime => 'Opening Time';

  @override
  String get closingTime => 'Closing Time';

  @override
  String get openWeekend => 'Open on weekends';

  @override
  String get createPdv => 'Create Store';

  @override
  String get enrollmentConfirmation => 'Enrollment Confirmation';

  @override
  String pdvCreatedSuccess(String name) {
    return 'The new store \'$name\' has been successfully created.';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get enterEmail => 'Please enter an email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get enterPhoneNumber => 'Please enter a phone number';

  @override
  String get enterPdvName => 'Please enter a store name';

  @override
  String get enterPercentage => 'Please enter a percentage';

  @override
  String get commissionRange => 'Commission must be between 0 and 100';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get enterAddress => 'Please enter an address';

  @override
  String get transactionList => 'Transfers List';

  @override
  String get totalTransactionAmount => 'Total Transfers Amount';

  @override
  String get noTransactions => 'No Transfers';

  @override
  String get viewReceipt => 'View Receipt';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get transactionReceipt => 'Transaction Receipt';

  @override
  String get receivedDate => 'Reception Date';

  @override
  String get transactionDate => 'Transaction Date';

  @override
  String get transactionNumber => 'Transaction Number';

  @override
  String get referenceNumber => 'Reference Number';

  @override
  String get transferReason => 'Transfer Reason';

  @override
  String get familyAssistance => 'Family assistance';

  @override
  String get beneficiary => 'Beneficiary';

  @override
  String get sender => 'Sender';

  @override
  String get transferDetails => 'Transfer Details';

  @override
  String get amountSent => 'Amount Sent';

  @override
  String get totalAmountIncludesTax => 'Total Amount (incl. tax)';

  @override
  String get receptionList => 'Received Transfers';

  @override
  String get totalReceptionAmount => 'Total Received Amount';

  @override
  String get noReceptions => 'No received transfers';

  @override
  String get receptionDetails => 'Reception Details';

  @override
  String get receptionReceipt => 'Reception Receipt';

  @override
  String get amountReceived => 'Amount Received';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get viewReceptionDetails => 'View details';

  @override
  String get nextStep => 'Continue';

  @override
  String get sendTransfer => 'Send Transfer';

  @override
  String get senderInformation => 'Sender Information';

  @override
  String get idType => 'ID Type';

  @override
  String get idNumber => 'ID Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get birthPlace => 'Place of Birth';

  @override
  String get country => 'Country';

  @override
  String get nationality => 'Nationality';

  @override
  String get searchNationality => 'Search for a nationality';

  @override
  String get selectBirthDate => 'Please select a birth date';

  @override
  String get selectExpiryDate => 'Please select an expiry date';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get senderInfoError => 'Error sending information';

  @override
  String get passport => 'Passport';

  @override
  String get identityCard => 'Identity Card';

  @override
  String get drivingLicense => 'Driving License';

  @override
  String get other => 'Other';

  @override
  String get recipientInformation => 'Recipient Information';

  @override
  String get recipientInfoError => 'Error when sending recipient information';

  @override
  String get billPayment => 'Bill payment';

  @override
  String get purchase => 'Purchase';

  @override
  String get confirmationError => 'An error occurred during confirmation';

  @override
  String errorOccurredWithDetails(String details) {
    return 'An error occurred: $details';
  }

  @override
  String get transferConfirmation => 'Transfer confirmation';

  @override
  String get transferProcessingMessage =>
      'The transfer request is being processed.';

  @override
  String referenceLabel(String id) {
    return 'Reference: $id';
  }

  @override
  String get receiptAvailabilityMessage =>
      'You can find the receipt in the transaction history at any time.';

  @override
  String get confirmationTitle => 'Confirmation';

  @override
  String get verifyInformationSubtitle => '(Verify your information)';

  @override
  String get incompleteSenderInfo => 'Incomplete sender information';

  @override
  String get incompleteRecipientInfo => 'Incomplete recipient information';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get receiveTransfer => 'Receive a transfer';

  @override
  String get enterTransferCode => 'Enter a transfer code';

  @override
  String get enterReferenceNumber => 'Please enter a reference number';

  @override
  String get verify => 'Verify';

  @override
  String get residenceCountry => 'Country of residence';

  @override
  String get futureExpiryDate => 'The expiry date must be in the future';

  @override
  String get receptionCreationError => 'Error creating the reception';

  @override
  String get receptionConfirmation => 'Reception confirmation';

  @override
  String get receptionProcessingMessage =>
      'The reception request is being processed.';

  @override
  String get receiptInReceptionHistory =>
      'You can find the receipt in the reception history at any time.';
}
