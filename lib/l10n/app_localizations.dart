import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MBE El Salvador'**
  String get appTitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// No description provided for @authHasAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'You already have an account. You can sign in with your password. If you don\'t remember it, you can recover it below.'**
  String get authHasAccountMessage;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authCompleteAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get authCompleteAllFields;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authRecover.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get authRecover;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authActivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate account'**
  String get authActivateAccount;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to get started'**
  String get welcomeSubtitle;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @authSendRecoveryLink.
  ///
  /// In en, this message translates to:
  /// **'Send recovery link'**
  String get authSendRecoveryLink;

  /// No description provided for @authRememberedPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get authRememberedPassword;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get emailSent;

  /// No description provided for @emailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a recovery link to:'**
  String get emailSentMessage;

  /// No description provided for @emailSentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and click the link to reset your password.'**
  String get emailSentInstructions;

  /// No description provided for @authUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get authUnderstood;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully reset. You can now sign in with your new password.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get goToSignIn;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit verification code to:'**
  String get verifyEmailCodeSent;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @codeResendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get codeResendQuestion;

  /// No description provided for @authResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get authResend;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to:'**
  String get otpEnterCode;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authResendCodeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend'**
  String get authResendCodeQuestion;

  /// No description provided for @invalidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get invalidCodeError;

  /// No description provided for @codeResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code resent to your email'**
  String get codeResentSuccess;

  /// No description provided for @resendCodeError.
  ///
  /// In en, this message translates to:
  /// **'Error resending code'**
  String get resendCodeError;

  /// No description provided for @codeDetectedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code detected from clipboard'**
  String get codeDetectedClipboard;

  /// No description provided for @enterSixDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit code'**
  String get enterSixDigits;

  /// No description provided for @enterSixDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit code'**
  String get enterSixDigitsError;

  /// No description provided for @createPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your password'**
  String get createPasswordTitle;

  /// No description provided for @createPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To secure your account, set a new password'**
  String get createPasswordSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @finishRegistration.
  ///
  /// In en, this message translates to:
  /// **'Finish Registration'**
  String get finishRegistration;

  /// No description provided for @passwordCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password created. You can now sign in.'**
  String get passwordCreatedSuccess;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @errorCreatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error creating password. Please try again.'**
  String get errorCreatingPassword;

  /// No description provided for @minEightChars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get minEightChars;

  /// No description provided for @includeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include an uppercase letter'**
  String get includeUppercase;

  /// No description provided for @includeLowercase.
  ///
  /// In en, this message translates to:
  /// **'Include a lowercase letter'**
  String get includeLowercase;

  /// No description provided for @includeNumber.
  ///
  /// In en, this message translates to:
  /// **'Include a number'**
  String get includeNumber;

  /// No description provided for @activateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate your account'**
  String get activateAccountTitle;

  /// No description provided for @activateAccountTitleAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate an account'**
  String get activateAccountTitleAnAccount;

  /// No description provided for @activateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Mail Boxes Etc. and enjoy our services'**
  String get activateAccountSubtitle;

  /// No description provided for @activationMessageDefault.
  ///
  /// In en, this message translates to:
  /// **'Hello! We see you already have an account with us. Let\'s activate it.'**
  String get activationMessageDefault;

  /// No description provided for @registerInfo.
  ///
  /// In en, this message translates to:
  /// **'Registration Information'**
  String get registerInfo;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to your email'**
  String get verificationCodeHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'First and last name'**
  String get fullNameHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @locker.
  ///
  /// In en, this message translates to:
  /// **'Locker'**
  String get locker;

  /// No description provided for @lockerEboxNote.
  ///
  /// In en, this message translates to:
  /// **'Remember you need to register in ebox to get your locker code.'**
  String get lockerEboxNote;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters, include uppercase, lowercase and numbers'**
  String get passwordHint;

  /// No description provided for @passwordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordsMatch;

  /// No description provided for @activateMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate my account'**
  String get activateMyAccount;

  /// No description provided for @accountActivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account activated successfully'**
  String get accountActivatedSuccess;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccess;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you accept our Terms of Service and Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @errorCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating your account. Please try again.'**
  String get errorCreatingAccount;

  /// No description provided for @registerStepInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get registerStepInfo;

  /// No description provided for @registerStepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get registerStepLocation;

  /// No description provided for @registerStepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get registerStepContact;

  /// No description provided for @registerStepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get registerStepSecurity;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @completeRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get completeRequiredFields;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @documentInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid document number'**
  String get documentInvalid;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone'**
  String get phoneInvalid;

  /// No description provided for @legacyWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! We see you already have a locker with us. Let\'s activate your digital account.'**
  String get legacyWelcomeMessage;

  /// No description provided for @newUserWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'You seem to be new. Let\'s create your account.'**
  String get newUserWelcomeMessage;

  /// No description provided for @biometricWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get biometricWelcomeBack;

  /// No description provided for @biometricSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your fingerprint or Face ID'**
  String get biometricSignInSubtitle;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get biometricNotAvailable;

  /// No description provided for @authSignInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get authSignInWithEmail;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogout;

  /// No description provided for @authCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancel;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get authLogoutConfirm;

  /// No description provided for @biometricTouchFaceId.
  ///
  /// In en, this message translates to:
  /// **'Tap to use Face ID'**
  String get biometricTouchFaceId;

  /// No description provided for @biometricTouchFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Tap to use fingerprint'**
  String get biometricTouchFingerprint;

  /// No description provided for @biometricTouchIris.
  ///
  /// In en, this message translates to:
  /// **'Tap to use iris'**
  String get biometricTouchIris;

  /// No description provided for @biometricTouchAuthenticate.
  ///
  /// In en, this message translates to:
  /// **'Tap to authenticate'**
  String get biometricTouchAuthenticate;

  /// No description provided for @authBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access your MBE account'**
  String get authBiometricReason;

  /// No description provided for @authCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication cancelled'**
  String get authCancelled;

  /// No description provided for @authUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get authUser;

  /// No description provided for @verificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPendingTitle;

  /// No description provided for @verificationPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is being reviewed by our administration team.'**
  String get verificationPendingMessage;

  /// No description provided for @verificationPendingDetail.
  ///
  /// In en, this message translates to:
  /// **'To create print orders or pre-alerts, an administrator needs to verify your account first.'**
  String get verificationPendingDetail;

  /// No description provided for @whatWeAreVerifying.
  ///
  /// In en, this message translates to:
  /// **'What are we verifying?'**
  String get whatWeAreVerifying;

  /// No description provided for @verificationDetail.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your email and locker code to ensure everything is correct.'**
  String get verificationDetail;

  /// No description provided for @emailNotification.
  ///
  /// In en, this message translates to:
  /// **'Email notification'**
  String get emailNotification;

  /// No description provided for @emailNotificationDetail.
  ///
  /// In en, this message translates to:
  /// **'You will receive an email when your account has been verified.'**
  String get emailNotificationDetail;

  /// No description provided for @completeProfileAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile and View Status'**
  String get completeProfileAndStatus;

  /// No description provided for @accountUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Account Under Review'**
  String get accountUnderReview;

  /// No description provided for @accountUnderReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your information. In the meantime, complete your profile to speed up the process.'**
  String get accountUnderReviewMessage;

  /// No description provided for @reviewingEmailLocker.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your email and locker code.'**
  String get reviewingEmailLocker;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide the following information to complete your registration'**
  String get completeProfileSubtitle;

  /// No description provided for @homePhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Home Phone (Optional)'**
  String get homePhoneOptional;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select document type'**
  String get selectDocumentType;

  /// No description provided for @errorLoadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Error loading document types'**
  String get errorLoadingDocuments;

  /// No description provided for @documentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get documentNumber;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @newAddress.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddress;

  /// No description provided for @yourAddresses.
  ///
  /// In en, this message translates to:
  /// **'Your Addresses'**
  String get yourAddresses;

  /// No description provided for @noAddresses.
  ///
  /// In en, this message translates to:
  /// **'You have no addresses'**
  String get noAddresses;

  /// No description provided for @addAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Add an address for your shipments'**
  String get addAddressHint;

  /// No description provided for @errorLoadingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Error loading addresses'**
  String get errorLoadingAddresses;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @activateAccountScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate your account'**
  String get activateAccountScreenTitle;

  /// No description provided for @activateAccountScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to check if you already have an account'**
  String get activateAccountScreenSubtitle;

  /// No description provided for @haveLockerCode.
  ///
  /// In en, this message translates to:
  /// **'Do you have a locker code?'**
  String get haveLockerCode;

  /// No description provided for @lockerCode.
  ///
  /// In en, this message translates to:
  /// **'Locker Code'**
  String get lockerCode;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email already registered'**
  String get emailAlreadyRegistered;

  /// No description provided for @emailAlreadyRegisteredMessage.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered in our system.'**
  String get emailAlreadyRegisteredMessage;

  /// No description provided for @forgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'If you forgot your password, you can recover it from the sign in screen.'**
  String get forgotPasswordHint;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {email}'**
  String verificationCodeSentTo(String email);

  /// No description provided for @errorVerifyingEmail.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while verifying the email. Please try again.'**
  String get errorVerifyingEmail;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spanish (ES)'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageSubtitleEn.
  ///
  /// In en, this message translates to:
  /// **'English (EN)'**
  String get settingsLanguageSubtitleEn;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingsAccount;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @errorSendingLink.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the link. Please try again.'**
  String get errorSendingLink;

  /// No description provided for @completeFieldsCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please complete all fields correctly'**
  String get completeFieldsCorrectly;

  /// No description provided for @errorResettingPassword.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while resetting the password. Please try again.'**
  String get errorResettingPassword;

  /// No description provided for @valid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get valid;

  /// No description provided for @loadingDocumentTypes.
  ///
  /// In en, this message translates to:
  /// **'Loading document types...'**
  String get loadingDocumentTypes;

  /// No description provided for @addressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address \"{name}\" saved successfully'**
  String addressSavedSuccess(String name);

  /// No description provided for @addressUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address \"{name}\" updated successfully'**
  String addressUpdatedSuccess(String name);

  /// No description provided for @errorSavingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error saving address'**
  String get errorSavingAddress;

  /// No description provided for @errorUpdatingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error updating address'**
  String get errorUpdatingAddress;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSavedSuccess;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get errorSavingProfile;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get homeGoodEvening;

  /// No description provided for @homeAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get homeAdminPanel;

  /// No description provided for @homeAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get homeAdministrator;

  /// No description provided for @homeYourLocker.
  ///
  /// In en, this message translates to:
  /// **'YOUR LOCKER'**
  String get homeYourLocker;

  /// No description provided for @homeAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get homeAddressCopied;

  /// No description provided for @homeInWarehouse.
  ///
  /// In en, this message translates to:
  /// **'In Warehouse'**
  String get homeInWarehouse;

  /// No description provided for @homeInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get homeInTransit;

  /// No description provided for @homeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get homeAvailable;

  /// No description provided for @homeWhatDoYouWant.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get homeWhatDoYouWant;

  /// No description provided for @homePreAlert.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert'**
  String get homePreAlert;

  /// No description provided for @homePreAlertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify your purchase'**
  String get homePreAlertSubtitle;

  /// No description provided for @homeQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get homeQuote;

  /// No description provided for @homeQuoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate costs'**
  String get homeQuoteSubtitle;

  /// No description provided for @homeMyPackages.
  ///
  /// In en, this message translates to:
  /// **'My Packages'**
  String get homeMyPackages;

  /// No description provided for @homeMyPackagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View inventory'**
  String get homeMyPackagesSubtitle;

  /// No description provided for @homeTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get homeTrack;

  /// No description provided for @homeTrackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track ID'**
  String get homeTrackSubtitle;

  /// No description provided for @homeSearchOffers.
  ///
  /// In en, this message translates to:
  /// **'Search offers'**
  String get homeSearchOffers;

  /// No description provided for @homeSearchOffersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore trends'**
  String get homeSearchOffersSubtitle;

  /// No description provided for @homePrintOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Print orders'**
  String get homePrintOrdersSubtitle;

  /// No description provided for @homeNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavHome;

  /// No description provided for @homeNavPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get homeNavPackages;

  /// No description provided for @homeNavRetrieval.
  ///
  /// In en, this message translates to:
  /// **'Retrieval'**
  String get homeNavRetrieval;

  /// No description provided for @homeNavSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeNavSearch;

  /// No description provided for @homeNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeNavProfile;

  /// No description provided for @homeNavPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get homeNavPrint;

  /// No description provided for @homeNavPreAlert.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert'**
  String get homeNavPreAlert;

  /// No description provided for @homeNavQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get homeNavQuote;

  /// No description provided for @homeNavTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get homeNavTrends;

  /// No description provided for @homeLockerRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'MBE Locker Registration'**
  String get homeLockerRegistrationTitle;

  /// No description provided for @homeCreateLocker.
  ///
  /// In en, this message translates to:
  /// **'Create locker'**
  String get homeCreateLocker;

  /// No description provided for @homeNoLocker.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a locker with us'**
  String get homeNoLocker;

  /// No description provided for @homeNoLockerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create one to receive your purchases in Miami and ship them to El Salvador.'**
  String get homeNoLockerSubtitle;

  /// No description provided for @homeOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get homeOpenLink;

  /// No description provided for @trendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Trends'**
  String get trendsTitle;

  /// No description provided for @trendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most searched products this week'**
  String get trendsSubtitle;

  /// No description provided for @adminQuickOps.
  ///
  /// In en, this message translates to:
  /// **'Quick Operations'**
  String get adminQuickOps;

  /// No description provided for @adminReception.
  ///
  /// In en, this message translates to:
  /// **'Reception'**
  String get adminReception;

  /// No description provided for @adminReceptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan incoming'**
  String get adminReceptionSubtitle;

  /// No description provided for @adminDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get adminDelivery;

  /// No description provided for @adminDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Correspondence'**
  String get adminDeliverySubtitle;

  /// No description provided for @adminInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get adminInventory;

  /// No description provided for @adminInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Query warehouse'**
  String get adminInventorySubtitle;

  /// No description provided for @adminReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminReports;

  /// No description provided for @adminReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get adminReportsSubtitle;

  /// No description provided for @adminNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get adminNeedsAttention;

  /// No description provided for @adminViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get adminViewAll;

  /// No description provided for @adminAlertedToday.
  ///
  /// In en, this message translates to:
  /// **'Alerted Today'**
  String get adminAlertedToday;

  /// No description provided for @adminReceivedToday.
  ///
  /// In en, this message translates to:
  /// **'Received Today'**
  String get adminReceivedToday;

  /// No description provided for @adminInWarehouse.
  ///
  /// In en, this message translates to:
  /// **'In Warehouse'**
  String get adminInWarehouse;

  /// No description provided for @adminDepartures.
  ///
  /// In en, this message translates to:
  /// **'Departures'**
  String get adminDepartures;

  /// No description provided for @adminSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search tracking, customer, locker...'**
  String get adminSearchPlaceholder;

  /// No description provided for @adminPackageNoInvoice.
  ///
  /// In en, this message translates to:
  /// **'Package without Invoice'**
  String get adminPackageNoInvoice;

  /// No description provided for @adminTrackingPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tracking: 1Z999... • 2h ago'**
  String get adminTrackingPlaceholder;

  /// No description provided for @drawerHello.
  ///
  /// In en, this message translates to:
  /// **'Hello! {name}'**
  String drawerHello(String name);

  /// No description provided for @drawerTierStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get drawerTierStandard;

  /// No description provided for @drawerSectionMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get drawerSectionMain;

  /// No description provided for @drawerSectionServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get drawerSectionServices;

  /// No description provided for @drawerSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get drawerSectionAccount;

  /// No description provided for @drawerSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get drawerSectionHelp;

  /// No description provided for @drawerSectionAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get drawerSectionAdmin;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @drawerAddresses.
  ///
  /// In en, this message translates to:
  /// **'Registered addresses'**
  String get drawerAddresses;

  /// No description provided for @drawerPromoCodes.
  ///
  /// In en, this message translates to:
  /// **'Promotional codes'**
  String get drawerPromoCodes;

  /// No description provided for @drawerRestrictedMaterials.
  ///
  /// In en, this message translates to:
  /// **'Restricted materials'**
  String get drawerRestrictedMaterials;

  /// No description provided for @drawerTrackPackage.
  ///
  /// In en, this message translates to:
  /// **'Track package'**
  String get drawerTrackPackage;

  /// No description provided for @drawerPreAlert.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert'**
  String get drawerPreAlert;

  /// No description provided for @drawerQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get drawerQuote;

  /// No description provided for @drawerYourPackages.
  ///
  /// In en, this message translates to:
  /// **'Your packages'**
  String get drawerYourPackages;

  /// No description provided for @drawerAdminPreAlerts.
  ///
  /// In en, this message translates to:
  /// **'Admin - Pre-Alerts'**
  String get drawerAdminPreAlerts;

  /// No description provided for @drawerPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get drawerPaymentMethods;

  /// No description provided for @drawerPremiumPlans.
  ///
  /// In en, this message translates to:
  /// **'Premium Plans'**
  String get drawerPremiumPlans;

  /// No description provided for @drawerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// No description provided for @drawerHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get drawerHistory;

  /// No description provided for @drawerNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get drawerNew;

  /// No description provided for @drawerFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get drawerFaq;

  /// No description provided for @drawerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get drawerContact;

  /// No description provided for @drawerTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get drawerTerms;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get drawerLogout;

  /// No description provided for @drawerLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get drawerLogoutConfirm;

  /// No description provided for @drawerLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to enter your credentials again.'**
  String get drawerLogoutMessage;

  /// No description provided for @drawerVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String drawerVersion(String version);

  /// No description provided for @preAlertNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Pre-alert'**
  String get preAlertNewTitle;

  /// No description provided for @preAlertNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete the information to register your package'**
  String get preAlertNewSubtitle;

  /// No description provided for @preAlertInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get preAlertInvoiceNumber;

  /// No description provided for @preAlertInvoiceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 112-9876543-1234567'**
  String get preAlertInvoiceHint;

  /// No description provided for @preAlertProductsInPackage.
  ///
  /// In en, this message translates to:
  /// **'Products in package'**
  String get preAlertProductsInPackage;

  /// No description provided for @preAlertAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get preAlertAddProduct;

  /// No description provided for @preAlertCategoryNote.
  ///
  /// In en, this message translates to:
  /// **'* Make sure to enter the correct category for your package, as it may cause delays in processing.'**
  String get preAlertCategoryNote;

  /// No description provided for @preAlertCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Pre-alert'**
  String get preAlertCreate;

  /// No description provided for @preAlertCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert created!'**
  String get preAlertCreatedSuccess;

  /// No description provided for @preAlertCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your pre-alert has been registered successfully'**
  String get preAlertCreatedMessage;

  /// No description provided for @preAlertAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get preAlertAccept;

  /// No description provided for @preAlertCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating pre-alert'**
  String get preAlertCreateError;

  /// No description provided for @preAlertStoreWhereBought.
  ///
  /// In en, this message translates to:
  /// **'Store where you bought the product'**
  String get preAlertStoreWhereBought;

  /// No description provided for @preAlertSelectStore.
  ///
  /// In en, this message translates to:
  /// **'Select a store'**
  String get preAlertSelectStore;

  /// No description provided for @preAlertSearchStore.
  ///
  /// In en, this message translates to:
  /// **'Search store...'**
  String get preAlertSearchStore;

  /// No description provided for @preAlertErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String preAlertErrorGeneric(String error);

  /// No description provided for @preAlertInvoiceForPurchase.
  ///
  /// In en, this message translates to:
  /// **'Invoice for this purchase'**
  String get preAlertInvoiceForPurchase;

  /// No description provided for @preAlertInvoiceUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Upload your invoice above with \"AI Autocomplete\". The same file will be sent with the pre-alert.'**
  String get preAlertInvoiceUploadHint;

  /// No description provided for @preAlertMyPreAlerts.
  ///
  /// In en, this message translates to:
  /// **'My Pre-alerts'**
  String get preAlertMyPreAlerts;

  /// No description provided for @preAlertNewPreAlert.
  ///
  /// In en, this message translates to:
  /// **'New Pre-alert'**
  String get preAlertNewPreAlert;

  /// No description provided for @preAlertRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get preAlertRetry;

  /// No description provided for @preAlertTracking.
  ///
  /// In en, this message translates to:
  /// **'TRACKING'**
  String get preAlertTracking;

  /// No description provided for @preAlertStore.
  ///
  /// In en, this message translates to:
  /// **'STORE'**
  String get preAlertStore;

  /// No description provided for @preAlertDate.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get preAlertDate;

  /// No description provided for @preAlertProducts.
  ///
  /// In en, this message translates to:
  /// **'PRODUCTS'**
  String get preAlertProducts;

  /// No description provided for @preAlertTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get preAlertTotal;

  /// No description provided for @preAlertNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get preAlertNoAddress;

  /// No description provided for @preAlertActionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get preAlertActionRequired;

  /// No description provided for @preAlertActionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You have packages in store that require selecting delivery method'**
  String get preAlertActionRequiredMessage;

  /// No description provided for @preAlertNoPreAlerts.
  ///
  /// In en, this message translates to:
  /// **'You have no pre-alerts'**
  String get preAlertNoPreAlerts;

  /// No description provided for @preAlertCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first package pre-alert'**
  String get preAlertCreateFirst;

  /// No description provided for @preAlertDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-alert Detail'**
  String get preAlertDetailTitle;

  /// No description provided for @preAlertDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load detail'**
  String get preAlertDetailLoadError;

  /// No description provided for @preAlertGeneralInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get preAlertGeneralInfo;

  /// No description provided for @preAlertTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get preAlertTrackingLabel;

  /// No description provided for @preAlertStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get preAlertStoreLabel;

  /// No description provided for @preAlertTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get preAlertTotalLabel;

  /// No description provided for @preAlertStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get preAlertStatus;

  /// No description provided for @preAlertClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get preAlertClient;

  /// No description provided for @preAlertEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get preAlertEmail;

  /// No description provided for @preAlertLocker.
  ///
  /// In en, this message translates to:
  /// **'Locker'**
  String get preAlertLocker;

  /// No description provided for @preAlertProductsSection.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get preAlertProductsSection;

  /// No description provided for @preAlertProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s)'**
  String preAlertProductCount(int count);

  /// No description provided for @preAlertNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get preAlertNoProducts;

  /// No description provided for @preAlertProductDefault.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get preAlertProductDefault;

  /// No description provided for @preAlertContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get preAlertContact;

  /// No description provided for @preAlertNoContactData.
  ///
  /// In en, this message translates to:
  /// **'No contact data'**
  String get preAlertNoContactData;

  /// No description provided for @preAlertDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get preAlertDelivery;

  /// No description provided for @preAlertName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get preAlertName;

  /// No description provided for @preAlertPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get preAlertPhone;

  /// No description provided for @preAlertAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get preAlertAddress;

  /// No description provided for @preAlertNoDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'No delivery address'**
  String get preAlertNoDeliveryAddress;

  /// No description provided for @preAlertChangeHistory.
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get preAlertChangeHistory;

  /// No description provided for @preAlertDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get preAlertDocument;

  /// No description provided for @preAlertPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get preAlertPayment;

  /// No description provided for @preAlertPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get preAlertPaid;

  /// No description provided for @preAlertPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get preAlertPending;

  /// No description provided for @preAlertLastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last payment'**
  String get preAlertLastPayment;

  /// No description provided for @preAlertCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Pre-alert'**
  String get preAlertCompleteTitle;

  /// No description provided for @preAlertStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String preAlertStepOf(int current, int total);

  /// No description provided for @preAlertViewPromotions.
  ///
  /// In en, this message translates to:
  /// **'View promotions'**
  String get preAlertViewPromotions;

  /// No description provided for @preAlertDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Delivery method'**
  String get preAlertDeliveryMethod;

  /// No description provided for @preAlertChooseDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to receive your package'**
  String get preAlertChooseDeliverySubtitle;

  /// No description provided for @preAlertContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get preAlertContactInfo;

  /// No description provided for @preAlertCompletePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment'**
  String get preAlertCompletePayment;

  /// No description provided for @preAlertSelectDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery method'**
  String get preAlertSelectDeliveryMethod;

  /// No description provided for @preAlertCompleteRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get preAlertCompleteRequiredFields;

  /// No description provided for @preAlertCompletePaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete payment information'**
  String get preAlertCompletePaymentInfo;

  /// No description provided for @preAlertCompleteAllSteps.
  ///
  /// In en, this message translates to:
  /// **'Please complete all steps before finishing'**
  String get preAlertCompleteAllSteps;

  /// No description provided for @preAlertSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get preAlertSelectPaymentMethod;

  /// No description provided for @preAlertCompleteError.
  ///
  /// In en, this message translates to:
  /// **'Error completing pre-alert: {error}'**
  String preAlertCompleteError(String error);

  /// No description provided for @preAlertCashSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your pre-alert has been completed. Payment will be made at delivery.'**
  String get preAlertCashSuccessMessage;

  /// No description provided for @preAlertPaymentRegisterError.
  ///
  /// In en, this message translates to:
  /// **'Error registering payment: {error}'**
  String preAlertPaymentRegisterError(String error);

  /// No description provided for @preAlertUploadTransferProof.
  ///
  /// In en, this message translates to:
  /// **'You must upload the transfer receipt'**
  String get preAlertUploadTransferProof;

  /// No description provided for @preAlertTransferReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'We have received your transfer receipt (ref: {ref}). The team will verify the payment and your pre-alert will be confirmed.'**
  String preAlertTransferReceivedMessage(String ref);

  /// No description provided for @preAlertTransferSendError.
  ///
  /// In en, this message translates to:
  /// **'Error sending receipt: {error}'**
  String preAlertTransferSendError(String error);

  /// No description provided for @preAlertPaymentInitError.
  ///
  /// In en, this message translates to:
  /// **'Error initiating payment: {error}'**
  String preAlertPaymentInitError(String error);

  /// No description provided for @preAlertPaymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully. The pre-alert has been completed.'**
  String get preAlertPaymentSuccessMessage;

  /// No description provided for @preAlertPaymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be completed. If you made the payment, the team will verify it.'**
  String get preAlertPaymentFailedMessage;

  /// No description provided for @preAlertPaymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get preAlertPaymentSuccessTitle;

  /// No description provided for @preAlertPaymentErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Error'**
  String get preAlertPaymentErrorTitle;

  /// No description provided for @preAlertPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment Cancelled'**
  String get preAlertPaymentCancelled;

  /// No description provided for @preAlertPaymentCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled. You can try again.'**
  String get preAlertPaymentCancelledMessage;

  /// No description provided for @preAlertBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get preAlertBack;

  /// No description provided for @preAlertContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get preAlertContinue;

  /// No description provided for @preAlertFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get preAlertFinish;

  /// No description provided for @preAlertFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get preAlertFrom;

  /// No description provided for @preAlertNoAdditionalCost.
  ///
  /// In en, this message translates to:
  /// **'No additional cost'**
  String get preAlertNoAdditionalCost;

  /// No description provided for @preAlertPickupInStore.
  ///
  /// In en, this message translates to:
  /// **'Pick up in Store'**
  String get preAlertPickupInStore;

  /// No description provided for @preAlertPickupDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick up your package at any of our locations'**
  String get preAlertPickupDescription;

  /// No description provided for @preAlertHomeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Home Delivery'**
  String get preAlertHomeDelivery;

  /// No description provided for @preAlertDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive your order at your door'**
  String get preAlertDeliveryDescription;

  /// No description provided for @preAlertSelectStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a store'**
  String get preAlertSelectStoreTitle;

  /// No description provided for @preAlertSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select an address'**
  String get preAlertSelectAddress;

  /// No description provided for @preAlertNoStores.
  ///
  /// In en, this message translates to:
  /// **'No stores available'**
  String get preAlertNoStores;

  /// No description provided for @preAlertErrorLoadingStores.
  ///
  /// In en, this message translates to:
  /// **'Error loading stores'**
  String get preAlertErrorLoadingStores;

  /// No description provided for @preAlertErrorLoadingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Error loading addresses'**
  String get preAlertErrorLoadingAddresses;

  /// No description provided for @preAlertNoAddresses.
  ///
  /// In en, this message translates to:
  /// **'You have no saved addresses'**
  String get preAlertNoAddresses;

  /// No description provided for @preAlertAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get preAlertAddAddress;

  /// No description provided for @preAlertNewAddress.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get preAlertNewAddress;

  /// No description provided for @preAlertDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get preAlertDefault;

  /// No description provided for @preAlertBaseCost.
  ///
  /// In en, this message translates to:
  /// **'Base cost'**
  String get preAlertBaseCost;

  /// No description provided for @preAlertEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get preAlertEstimatedTime;

  /// No description provided for @preAlertEstimatedTimeValue.
  ///
  /// In en, this message translates to:
  /// **'1-2 business days'**
  String get preAlertEstimatedTimeValue;

  /// No description provided for @preAlertSaveAmount.
  ///
  /// In en, this message translates to:
  /// **'You save {amount}'**
  String preAlertSaveAmount(String amount);

  /// No description provided for @preAlertContactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get preAlertContactInfoTitle;

  /// No description provided for @preAlertContactInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your contact details'**
  String get preAlertContactInfoSubtitle;

  /// No description provided for @preAlertFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get preAlertFullName;

  /// No description provided for @preAlertFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get preAlertFullNameHint;

  /// No description provided for @preAlertEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get preAlertEmailLabel;

  /// No description provided for @preAlertEmailHint.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get preAlertEmailHint;

  /// No description provided for @preAlertPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get preAlertPhoneLabel;

  /// No description provided for @preAlertPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'(000) 000-0000'**
  String get preAlertPhoneHint;

  /// No description provided for @preAlertNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get preAlertNotesOptional;

  /// No description provided for @preAlertNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Call before pickup, preferred time...'**
  String get preAlertNotesHint;

  /// No description provided for @preAlertDifferentReceiver.
  ///
  /// In en, this message translates to:
  /// **'Is the receiver different?'**
  String get preAlertDifferentReceiver;

  /// No description provided for @preAlertDifferentReceiverDesc.
  ///
  /// In en, this message translates to:
  /// **'Check this option if someone else will receive the package'**
  String get preAlertDifferentReceiverDesc;

  /// No description provided for @preAlertReceiverInfo.
  ///
  /// In en, this message translates to:
  /// **'Receiver Information'**
  String get preAlertReceiverInfo;

  /// No description provided for @preAlertReceiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get preAlertReceiverName;

  /// No description provided for @preAlertReceiverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Receiver full name'**
  String get preAlertReceiverNameHint;

  /// No description provided for @preAlertReceiverEmail.
  ///
  /// In en, this message translates to:
  /// **'Receiver email'**
  String get preAlertReceiverEmail;

  /// No description provided for @preAlertReceiverPhone.
  ///
  /// In en, this message translates to:
  /// **'Receiver phone'**
  String get preAlertReceiverPhone;

  /// No description provided for @preAlertPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get preAlertPaymentInfo;

  /// No description provided for @preAlertPaymentInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete payment details'**
  String get preAlertPaymentInfoSubtitle;

  /// No description provided for @preAlertTotalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get preAlertTotalToPay;

  /// No description provided for @preAlertPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get preAlertPaymentMethod;

  /// No description provided for @preAlertBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get preAlertBankTransfer;

  /// No description provided for @preAlertBankTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload transfer receipt (image or PDF). It will be reviewed by the team.'**
  String get preAlertBankTransferDesc;

  /// No description provided for @preAlertCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash (on delivery)'**
  String get preAlertCashOnDelivery;

  /// No description provided for @preAlertCashOnDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay in cash when you receive your package.'**
  String get preAlertCashOnDeliveryDesc;

  /// No description provided for @preAlertTransferProof.
  ///
  /// In en, this message translates to:
  /// **'Transfer receipt'**
  String get preAlertTransferProof;

  /// No description provided for @preAlertSelectImageOrPdf.
  ///
  /// In en, this message translates to:
  /// **'Select image or PDF'**
  String get preAlertSelectImageOrPdf;

  /// No description provided for @preAlertProofSelected.
  ///
  /// In en, this message translates to:
  /// **'Receipt selected'**
  String get preAlertProofSelected;

  /// No description provided for @preAlertBankReferenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Bank reference (optional)'**
  String get preAlertBankReferenceOptional;

  /// No description provided for @preAlertNotesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get preAlertNotesOptionalLabel;

  /// No description provided for @preAlertCashPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment will be made at the time of delivery of your package.'**
  String get preAlertCashPaymentInfo;

  /// No description provided for @preAlertAutocompleteAI.
  ///
  /// In en, this message translates to:
  /// **'AI Autocomplete'**
  String get preAlertAutocompleteAI;

  /// No description provided for @preAlertAutocompleteAIDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your invoice (PDF or image) and AI will fill out the form for you. The same file will be sent with the pre-alert.'**
  String get preAlertAutocompleteAIDesc;

  /// No description provided for @preAlertChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get preAlertChange;

  /// No description provided for @preAlertUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload file'**
  String get preAlertUploadFile;

  /// No description provided for @preAlertAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing with AI...'**
  String get preAlertAnalyzing;

  /// No description provided for @preAlertReadingInvoice.
  ///
  /// In en, this message translates to:
  /// **'AI is reading your invoice'**
  String get preAlertReadingInvoice;

  /// No description provided for @preAlertFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File cannot exceed 10 MB'**
  String get preAlertFileTooLarge;

  /// No description provided for @preAlertErrorSelecting.
  ///
  /// In en, this message translates to:
  /// **'Error selecting: {error}'**
  String preAlertErrorSelecting(String error);

  /// No description provided for @preAlertProductItem.
  ///
  /// In en, this message translates to:
  /// **'Product {index}'**
  String preAlertProductItem(int index);

  /// No description provided for @preAlertProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Product Category'**
  String get preAlertProductCategory;

  /// No description provided for @preAlertSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select or search a category...'**
  String get preAlertSelectCategory;

  /// No description provided for @preAlertSearchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search category...'**
  String get preAlertSearchCategory;

  /// No description provided for @preAlertQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get preAlertQuantity;

  /// No description provided for @preAlertPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get preAlertPrice;

  /// No description provided for @preAlertSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get preAlertSubtotal;

  /// No description provided for @preAlertPromotionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available Promotions'**
  String get preAlertPromotionsAvailable;

  /// No description provided for @preAlertPromotionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take advantage of our special offers'**
  String get preAlertPromotionsSubtitle;

  /// No description provided for @preAlertNoPromotions.
  ///
  /// In en, this message translates to:
  /// **'No promotions available at this time'**
  String get preAlertNoPromotions;

  /// No description provided for @preAlertSelectDeliveryFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery method first'**
  String get preAlertSelectDeliveryFirst;

  /// No description provided for @preAlertErrorLoadingPromotion.
  ///
  /// In en, this message translates to:
  /// **'Error loading promotion: {error}'**
  String preAlertErrorLoadingPromotion(String error);

  /// No description provided for @preAlertClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get preAlertClose;

  /// No description provided for @preAlertPromotion.
  ///
  /// In en, this message translates to:
  /// **'PROMOTION'**
  String get preAlertPromotion;

  /// No description provided for @preAlertEstimatedSavings.
  ///
  /// In en, this message translates to:
  /// **'Estimated savings'**
  String get preAlertEstimatedSavings;

  /// No description provided for @preAlertProcessingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment'**
  String get preAlertProcessingPayment;

  /// No description provided for @preAlertLoadingPaymentForm.
  ///
  /// In en, this message translates to:
  /// **'Loading payment form...'**
  String get preAlertLoadingPaymentForm;

  /// No description provided for @preAlertErrorLoadingPage.
  ///
  /// In en, this message translates to:
  /// **'Error loading page: {error}'**
  String preAlertErrorLoadingPage(String error);

  /// No description provided for @preAlertNoAddressFallback.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get preAlertNoAddressFallback;

  /// No description provided for @printOrderCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create order'**
  String get printOrderCreateTitle;

  /// No description provided for @printOrderMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get printOrderMyOrders;

  /// No description provided for @printOrderNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get printOrderNewOrder;

  /// No description provided for @printOrderSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get printOrderSaveDraft;

  /// No description provided for @printOrderResetOrder.
  ///
  /// In en, this message translates to:
  /// **'Reset order'**
  String get printOrderResetOrder;

  /// No description provided for @printOrderHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get printOrderHelp;

  /// No description provided for @printOrderCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order created!'**
  String get printOrderCreatedSuccess;

  /// No description provided for @printOrderCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order has been created successfully'**
  String get printOrderCreatedMessage;

  /// No description provided for @printOrderCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating order'**
  String get printOrderCreateError;

  /// No description provided for @printOrderUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String printOrderUnexpectedError(String error);

  /// No description provided for @printOrderNoOrders.
  ///
  /// In en, this message translates to:
  /// **'You have no orders'**
  String get printOrderNoOrders;

  /// No description provided for @printOrderCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first print order'**
  String get printOrderCreateFirst;

  /// No description provided for @printOrderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get printOrderDetailTitle;

  /// No description provided for @printOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get printOrderHistory;

  /// No description provided for @printOrderConfig.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get printOrderConfig;

  /// No description provided for @printOrderFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get printOrderFiles;

  /// No description provided for @printOrderPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get printOrderPages;

  /// No description provided for @printOrderPagesShort.
  ///
  /// In en, this message translates to:
  /// **'pgs'**
  String get printOrderPagesShort;

  /// No description provided for @printOrderTotalOrder.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get printOrderTotalOrder;

  /// No description provided for @printOrderOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get printOrderOrderDate;

  /// No description provided for @printOrderNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get printOrderNeedHelp;

  /// No description provided for @printOrderHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about your order, contact us.'**
  String get printOrderHelpMessage;

  /// No description provided for @printOrderMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get printOrderMethod;

  /// No description provided for @printOrderLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get printOrderLocation;

  /// No description provided for @printOrderType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get printOrderType;

  /// No description provided for @printOrderSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get printOrderSize;

  /// No description provided for @printOrderCopies.
  ///
  /// In en, this message translates to:
  /// **'Copies'**
  String get printOrderCopies;

  /// No description provided for @printOrderColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get printOrderColor;

  /// No description provided for @printOrderBW.
  ///
  /// In en, this message translates to:
  /// **'B/W'**
  String get printOrderBW;

  /// No description provided for @printOrderPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get printOrderPickup;

  /// No description provided for @printOrderShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get printOrderShipping;

  /// No description provided for @printOrderStepFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get printOrderStepFiles;

  /// No description provided for @printOrderStepFilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents'**
  String get printOrderStepFilesDesc;

  /// No description provided for @printOrderStepConfig.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get printOrderStepConfig;

  /// No description provided for @printOrderStepConfigDesc.
  ///
  /// In en, this message translates to:
  /// **'Print options'**
  String get printOrderStepConfigDesc;

  /// No description provided for @printOrderStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get printOrderStepConfirm;

  /// No description provided for @printOrderStepConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Review order'**
  String get printOrderStepConfirmDesc;

  /// No description provided for @printOrderConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get printOrderConfirmTitle;

  /// No description provided for @printOrderConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and complete your information'**
  String get printOrderConfirmSubtitle;

  /// No description provided for @printOrderLoadingConfig.
  ///
  /// In en, this message translates to:
  /// **'Loading configuration...'**
  String get printOrderLoadingConfig;

  /// No description provided for @printOrderErrorLoadingConfig.
  ///
  /// In en, this message translates to:
  /// **'Error loading configuration'**
  String get printOrderErrorLoadingConfig;

  /// No description provided for @printOrderUploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload files'**
  String get printOrderUploadFiles;

  /// No description provided for @printOrderUploadFilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag or select your documents'**
  String get printOrderUploadFilesDesc;

  /// No description provided for @printOrderDropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop your files here!'**
  String get printOrderDropFilesHere;

  /// No description provided for @printOrderDragFiles.
  ///
  /// In en, this message translates to:
  /// **'Drag your files'**
  String get printOrderDragFiles;

  /// No description provided for @printOrderOrClickToSelect.
  ///
  /// In en, this message translates to:
  /// **'or click to select'**
  String get printOrderOrClickToSelect;

  /// No description provided for @printOrderSelectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select files'**
  String get printOrderSelectFiles;

  /// No description provided for @printOrderFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF, Word'**
  String get printOrderFormats;

  /// No description provided for @printOrderImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get printOrderImages;

  /// No description provided for @printOrderUpToMB.
  ///
  /// In en, this message translates to:
  /// **'Up to {mb}MB'**
  String printOrderUpToMB(int mb);

  /// No description provided for @printOrderNoPagesDetected.
  ///
  /// In en, this message translates to:
  /// **'No pages detected'**
  String get printOrderNoPagesDetected;

  /// No description provided for @printOrderGoBackAndUpload.
  ///
  /// In en, this message translates to:
  /// **'Go back to the previous step and upload your files'**
  String get printOrderGoBackAndUpload;

  /// No description provided for @printOrderChooseReceiveOrder.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to receive your order'**
  String get printOrderChooseReceiveOrder;

  /// No description provided for @printOrderFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free shipping!'**
  String get printOrderFreeShipping;

  /// No description provided for @printOrderMakePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get printOrderMakePayment;

  /// No description provided for @printOrderSecurePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure payment with encryption'**
  String get printOrderSecurePayment;

  /// No description provided for @printOrderFileReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get printOrderFileReady;

  /// No description provided for @printOrderFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected files'**
  String get printOrderFilesSelected;

  /// No description provided for @printOrderFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {max} files'**
  String printOrderFilesCount(int current, int max);

  /// No description provided for @printOrderTotalSize.
  ///
  /// In en, this message translates to:
  /// **'Total size'**
  String get printOrderTotalSize;

  /// No description provided for @printOrderAcceptedFormats.
  ///
  /// In en, this message translates to:
  /// **'Accepted formats'**
  String get printOrderAcceptedFormats;

  /// No description provided for @printOrderFilesLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to {maxFiles} files • {maxMB}MB per file'**
  String printOrderFilesLimit(int maxFiles, int maxMB);

  /// No description provided for @printOrderTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for best results'**
  String get printOrderTipsTitle;

  /// No description provided for @printOrderTipPdf.
  ///
  /// In en, this message translates to:
  /// **'• Use PDF files for better quality'**
  String get printOrderTipPdf;

  /// No description provided for @printOrderTipReadable.
  ///
  /// In en, this message translates to:
  /// **'• Make sure the text is readable'**
  String get printOrderTipReadable;

  /// No description provided for @printOrderTipResolution.
  ///
  /// In en, this message translates to:
  /// **'• Images should have good resolution'**
  String get printOrderTipResolution;

  /// No description provided for @printOrderPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get printOrderPaymentCard;

  /// No description provided for @printOrderPaymentCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Debit or credit'**
  String get printOrderPaymentCardDesc;

  /// No description provided for @printOrderPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get printOrderPaymentCash;

  /// No description provided for @printOrderPaymentCashDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay when you receive your order'**
  String get printOrderPaymentCashDesc;

  /// No description provided for @printOrderPaymentTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get printOrderPaymentTransfer;

  /// No description provided for @printOrderPaymentTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Bank, BAC, etc.'**
  String get printOrderPaymentTransferDesc;

  /// No description provided for @printOrderOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get printOrderOrderSummary;

  /// No description provided for @printOrderDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get printOrderDocuments;

  /// No description provided for @printOrderTotalPages.
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get printOrderTotalPages;

  /// No description provided for @printOrderCostBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Cost Breakdown'**
  String get printOrderCostBreakdown;

  /// No description provided for @printOrderPrintSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Print subtotal'**
  String get printOrderPrintSubtotal;

  /// No description provided for @printOrderShippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get printOrderShippingCost;

  /// No description provided for @printOrderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get printOrderTotal;

  /// No description provided for @printOrderPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get printOrderPaymentMethodLabel;

  /// No description provided for @printOrderEmailConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You will receive an email with your order details'**
  String get printOrderEmailConfirmation;

  /// No description provided for @printOrderSecurePaymentFull.
  ///
  /// In en, this message translates to:
  /// **'100% secure and encrypted payment'**
  String get printOrderSecurePaymentFull;

  /// No description provided for @printOrderCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Card Information'**
  String get printOrderCardInfo;

  /// No description provided for @printOrderAmountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get printOrderAmountToPay;

  /// No description provided for @printOrderErrorProcessing.
  ///
  /// In en, this message translates to:
  /// **'Error processing order'**
  String get printOrderErrorProcessing;

  /// No description provided for @printOrderTermsAccept.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our terms and conditions of service'**
  String get printOrderTermsAccept;

  /// No description provided for @printOrderCashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash payment'**
  String get printOrderCashPayment;

  /// No description provided for @printOrderTransferPayment.
  ///
  /// In en, this message translates to:
  /// **'Transfer payment'**
  String get printOrderTransferPayment;

  /// No description provided for @printOrderCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card payment'**
  String get printOrderCardPayment;

  /// No description provided for @printOrderCashPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'You will pay when you receive your order'**
  String get printOrderCashPaymentDesc;

  /// No description provided for @printOrderTransferPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'You will receive instructions by email'**
  String get printOrderTransferPaymentDesc;

  /// No description provided for @printOrderCardPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with your card'**
  String get printOrderCardPaymentDesc;

  /// No description provided for @printOrderCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get printOrderCardNumber;

  /// No description provided for @printOrderCardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'1234 5678 9012 3456'**
  String get printOrderCardNumberHint;

  /// No description provided for @printOrderCardHolder.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get printOrderCardHolder;

  /// No description provided for @printOrderCardHolderHint.
  ///
  /// In en, this message translates to:
  /// **'As it appears on the card'**
  String get printOrderCardHolderHint;

  /// No description provided for @printOrderExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get printOrderExpiry;

  /// No description provided for @printOrderExpiryHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get printOrderExpiryHint;

  /// No description provided for @printOrderNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any special instructions...'**
  String get printOrderNotesHint;

  /// No description provided for @printOrderPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get printOrderPhoneOptional;

  /// No description provided for @printOrderOrientationPortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get printOrderOrientationPortrait;

  /// No description provided for @printOrderOrientationLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get printOrderOrientationLandscape;

  /// No description provided for @printOrderDoubleSided.
  ///
  /// In en, this message translates to:
  /// **'Double-sided'**
  String get printOrderDoubleSided;

  /// No description provided for @printOrderBinding.
  ///
  /// In en, this message translates to:
  /// **'Binding'**
  String get printOrderBinding;

  /// No description provided for @printOrderYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get printOrderYes;

  /// No description provided for @printOrderAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get printOrderAddress;

  /// No description provided for @printOrderPickupInStore.
  ///
  /// In en, this message translates to:
  /// **'Pick up in store'**
  String get printOrderPickupInStore;

  /// No description provided for @printOrderHomeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Home delivery'**
  String get printOrderHomeDelivery;

  /// No description provided for @printOrderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get printOrderTypeLabel;

  /// No description provided for @printOrderSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get printOrderSizeLabel;

  /// No description provided for @printOrderOrientationLabel.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get printOrderOrientationLabel;

  /// No description provided for @printOrderCopiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Copies'**
  String get printOrderCopiesLabel;

  /// No description provided for @printOrderBwLabel.
  ///
  /// In en, this message translates to:
  /// **'B/W'**
  String get printOrderBwLabel;

  /// No description provided for @printOrderColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get printOrderColorLabel;

  /// No description provided for @printOrderLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get printOrderLetter;

  /// No description provided for @printOrderLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get printOrderLegal;

  /// No description provided for @printOrderDoubleLetter.
  ///
  /// In en, this message translates to:
  /// **'Double Letter'**
  String get printOrderDoubleLetter;

  /// No description provided for @printOrderConfigurePrint.
  ///
  /// In en, this message translates to:
  /// **'Configure Print'**
  String get printOrderConfigurePrint;

  /// No description provided for @printOrderCustomizeOrder.
  ///
  /// In en, this message translates to:
  /// **'Customize your order • {pages} pages'**
  String printOrderCustomizeOrder(int pages);

  /// No description provided for @printOrderPrintType.
  ///
  /// In en, this message translates to:
  /// **'Print Type'**
  String get printOrderPrintType;

  /// No description provided for @printOrderPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get printOrderPaper;

  /// No description provided for @printOrderPaperType.
  ///
  /// In en, this message translates to:
  /// **'Paper Type'**
  String get printOrderPaperType;

  /// No description provided for @printOrderAdditionalOptions.
  ///
  /// In en, this message translates to:
  /// **'Additional Options'**
  String get printOrderAdditionalOptions;

  /// No description provided for @printOrderDoubleSidedPrint.
  ///
  /// In en, this message translates to:
  /// **'Double-sided Print'**
  String get printOrderDoubleSidedPrint;

  /// No description provided for @printOrderSavePaper.
  ///
  /// In en, this message translates to:
  /// **'Save paper'**
  String get printOrderSavePaper;

  /// No description provided for @printOrderProfessionalPresentation.
  ///
  /// In en, this message translates to:
  /// **'Professional presentation'**
  String get printOrderProfessionalPresentation;

  /// No description provided for @printOrderCostSummary.
  ///
  /// In en, this message translates to:
  /// **'Cost Summary'**
  String get printOrderCostSummary;

  /// No description provided for @printOrderPrintingLabel.
  ///
  /// In en, this message translates to:
  /// **'Printing'**
  String get printOrderPrintingLabel;

  /// No description provided for @printOrderPerPage.
  ///
  /// In en, this message translates to:
  /// **'per page'**
  String get printOrderPerPage;

  /// No description provided for @printOrderCopy.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get printOrderCopy;

  /// No description provided for @printOrderSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get printOrderSubtotal;

  /// No description provided for @printOrderBondPaper.
  ///
  /// In en, this message translates to:
  /// **'Bond Paper'**
  String get printOrderBondPaper;

  /// No description provided for @printOrderGlossyPaper.
  ///
  /// In en, this message translates to:
  /// **'Glossy Paper'**
  String get printOrderGlossyPaper;

  /// No description provided for @printOrderStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get printOrderStandard;

  /// No description provided for @printOrderForImages.
  ///
  /// In en, this message translates to:
  /// **'For images'**
  String get printOrderForImages;

  /// No description provided for @printOrderNumberOfCopies.
  ///
  /// In en, this message translates to:
  /// **'Number of Copies'**
  String get printOrderNumberOfCopies;

  /// No description provided for @printOrderMaxCopies.
  ///
  /// In en, this message translates to:
  /// **'Up to 100 copies'**
  String get printOrderMaxCopies;

  /// No description provided for @printOrderEco.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get printOrderEco;

  /// No description provided for @profileMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileMyProfile;

  /// No description provided for @profileNoSession.
  ///
  /// In en, this message translates to:
  /// **'No session'**
  String get profileNoSession;

  /// No description provided for @profileEditInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get profileEditInfo;

  /// No description provided for @profilePersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get profilePersonalData;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profilePasswordAccess.
  ///
  /// In en, this message translates to:
  /// **'Password and access'**
  String get profilePasswordAccess;

  /// No description provided for @profileMyAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get profileMyAddresses;

  /// No description provided for @profileManageDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Manage deliveries'**
  String get profileManageDeliveries;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get profileHelpSupport;

  /// No description provided for @profileHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get profileHelpCenter;

  /// No description provided for @profileAdministrator.
  ///
  /// In en, this message translates to:
  /// **'ADMINISTRATOR'**
  String get profileAdministrator;

  /// No description provided for @profileClientMbe.
  ///
  /// In en, this message translates to:
  /// **'MBE CLIENT'**
  String get profileClientMbe;

  /// No description provided for @profilePackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get profilePackages;

  /// No description provided for @profilePoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profilePoints;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String profileError(String error);

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get profileNameRequired;

  /// No description provided for @profilePhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone format'**
  String get profilePhoneInvalid;

  /// No description provided for @profileEmailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed from the app.'**
  String get profileEmailCannotChange;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileCurrentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get profileCurrentPasswordRequired;

  /// No description provided for @profileNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get profileNewPasswordRequired;

  /// No description provided for @profilePasswordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters, with uppercase, lowercase and a number'**
  String get profilePasswordRequirements;

  /// No description provided for @profilePasswordDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current'**
  String get profilePasswordDifferent;

  /// No description provided for @profilePasswordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get profilePasswordUpdatedSuccess;

  /// No description provided for @profilePasswordChangeError.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get profilePasswordChangeError;

  /// No description provided for @profileCurrentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get profileCurrentPasswordIncorrect;

  /// No description provided for @profileProtectAccount.
  ///
  /// In en, this message translates to:
  /// **'To protect your account, enter your current password.'**
  String get profileProtectAccount;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get profileCurrentPassword;

  /// No description provided for @profileUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get profileUpdatePassword;

  /// No description provided for @profileDeleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently deleted.'**
  String profileDeleteAddressConfirm(String name);

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDelete;

  /// No description provided for @profileDeleteAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete address?'**
  String get profileDeleteAddressTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profilePrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get profilePrimary;

  /// No description provided for @profileMakeDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Primary'**
  String get profileMakeDefault;

  /// No description provided for @profileNewAddress.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get profileNewAddress;

  /// No description provided for @profileNoAddressesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No registered addresses'**
  String get profileNoAddressesRegistered;

  /// No description provided for @profileAddAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Add an address to receive\nyour packages faster'**
  String get profileAddAddressHint;

  /// No description provided for @profileAddFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add First Address'**
  String get profileAddFirstAddress;

  /// No description provided for @profileErrorSavingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error saving address: {error}'**
  String profileErrorSavingAddress(String error);

  /// No description provided for @profileAddressNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Address name is required'**
  String get profileAddressNameRequired;

  /// No description provided for @profileDepartmentRequired.
  ///
  /// In en, this message translates to:
  /// **'You must select a department'**
  String get profileDepartmentRequired;

  /// No description provided for @profileMunicipalityRequired.
  ///
  /// In en, this message translates to:
  /// **'You must select a municipality'**
  String get profileMunicipalityRequired;

  /// No description provided for @profileAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get profileAddressRequired;

  /// No description provided for @profilePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get profilePhoneRequired;

  /// No description provided for @profileEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get profileEditAddress;

  /// No description provided for @profileCompleteAddressData.
  ///
  /// In en, this message translates to:
  /// **'Complete the data for your shipments'**
  String get profileCompleteAddressData;

  /// No description provided for @profileAddressAlias.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS ALIAS'**
  String get profileAddressAlias;

  /// No description provided for @profileAddressAliasHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Office, Warehouse...'**
  String get profileAddressAliasHint;

  /// No description provided for @profileLocation.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get profileLocation;

  /// No description provided for @profileDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get profileDepartment;

  /// No description provided for @profileMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get profileMunicipality;

  /// No description provided for @profileDistrictOptional.
  ///
  /// In en, this message translates to:
  /// **'District / Subzone (Optional)'**
  String get profileDistrictOptional;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get profileDetails;

  /// No description provided for @profileDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Street, passage, house number, neighborhood...'**
  String get profileDetailsHint;

  /// No description provided for @profileReferencesHint.
  ///
  /// In en, this message translates to:
  /// **'References (Black gate, in front of park...)'**
  String get profileReferencesHint;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'PHONE'**
  String get profilePhoneLabel;

  /// No description provided for @profileMainAddress.
  ///
  /// In en, this message translates to:
  /// **'Primary Address'**
  String get profileMainAddress;

  /// No description provided for @profileUseForShipments.
  ///
  /// In en, this message translates to:
  /// **'Use for my next shipments'**
  String get profileUseForShipments;

  /// No description provided for @profileSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get profileSaveAddress;

  /// No description provided for @profileUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get profileUpdate;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get profileLoading;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileUpdateNameEmail.
  ///
  /// In en, this message translates to:
  /// **'Update your name and email'**
  String get profileUpdateNameEmail;

  /// No description provided for @profileContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get profileContactInfo;

  /// No description provided for @profileUpdateContactDocument.
  ///
  /// In en, this message translates to:
  /// **'Update your contact and document information'**
  String get profileUpdateContactDocument;

  /// No description provided for @profileDocumentDui.
  ///
  /// In en, this message translates to:
  /// **'Unique Identity Document'**
  String get profileDocumentDui;

  /// No description provided for @profileDocumentPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get profileDocumentPassport;

  /// No description provided for @profileDocumentLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get profileDocumentLicense;

  /// No description provided for @profileSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get profileSelectType;

  /// No description provided for @profileFormatDui.
  ///
  /// In en, this message translates to:
  /// **'Format: 12345678-9'**
  String get profileFormatDui;

  /// No description provided for @quoteCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping Calculator'**
  String get quoteCalculatorTitle;

  /// No description provided for @quotePackageDetails.
  ///
  /// In en, this message translates to:
  /// **'Package Details'**
  String get quotePackageDetails;

  /// No description provided for @quoteWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get quoteWeight;

  /// No description provided for @quoteValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get quoteValue;

  /// No description provided for @quoteProductType.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get quoteProductType;

  /// No description provided for @quoteErrorCalculating.
  ///
  /// In en, this message translates to:
  /// **'Error calculating: {error}'**
  String quoteErrorCalculating(String error);

  /// No description provided for @quoteGenerated.
  ///
  /// In en, this message translates to:
  /// **'Quote Generated'**
  String get quoteGenerated;

  /// No description provided for @quoteBasedOnRates.
  ///
  /// In en, this message translates to:
  /// **'Based on current rates'**
  String get quoteBasedOnRates;

  /// No description provided for @quoteApproxWeight.
  ///
  /// In en, this message translates to:
  /// **'Approximate weight (original: {weight} lbs)'**
  String quoteApproxWeight(String weight);

  /// No description provided for @quoteShippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping Cost'**
  String get quoteShippingCost;

  /// No description provided for @quoteDeliveryGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Guarantee'**
  String get quoteDeliveryGuarantee;

  /// No description provided for @quoteCustomsTaxes.
  ///
  /// In en, this message translates to:
  /// **'Customs Taxes'**
  String get quoteCustomsTaxes;

  /// No description provided for @quoteIvaCif.
  ///
  /// In en, this message translates to:
  /// **'IVA-CIF'**
  String get quoteIvaCif;

  /// No description provided for @quoteDai.
  ///
  /// In en, this message translates to:
  /// **'DAI ({rate}%)'**
  String quoteDai(String rate);

  /// No description provided for @quoteTotalTaxes.
  ///
  /// In en, this message translates to:
  /// **'Total Taxes'**
  String get quoteTotalTaxes;

  /// No description provided for @quoteCustomsManagement.
  ///
  /// In en, this message translates to:
  /// **'Customs Management'**
  String get quoteCustomsManagement;

  /// No description provided for @quoteThirdPartyHandling.
  ///
  /// In en, this message translates to:
  /// **'Third Party Handling'**
  String get quoteThirdPartyHandling;

  /// No description provided for @quoteDiscountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount applied'**
  String get quoteDiscountApplied;

  /// No description provided for @quoteTotalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to Pay:'**
  String get quoteTotalToPay;

  /// No description provided for @trendsAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Shopping Advisor'**
  String get trendsAdvisor;

  /// No description provided for @trendsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get trendsViewAll;

  /// No description provided for @trendsTrending1.
  ///
  /// In en, this message translates to:
  /// **'Trend #1'**
  String get trendsTrending1;

  /// No description provided for @trendsApproxPrice.
  ///
  /// In en, this message translates to:
  /// **'Approx. Price'**
  String get trendsApproxPrice;

  /// No description provided for @trendsSeeOffer.
  ///
  /// In en, this message translates to:
  /// **'See Offer'**
  String get trendsSeeOffer;

  /// No description provided for @trendsHot.
  ///
  /// In en, this message translates to:
  /// **'HOT'**
  String get trendsHot;

  /// No description provided for @trendsSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get trendsSomethingWrong;

  /// No description provided for @trendsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get trendsTryAgain;

  /// No description provided for @adminContextReception.
  ///
  /// In en, this message translates to:
  /// **'Reception'**
  String get adminContextReception;

  /// No description provided for @adminContextLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminContextLocation;

  /// No description provided for @adminContextDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get adminContextDelivery;

  /// No description provided for @adminContextScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get adminContextScan;

  /// No description provided for @adminReadyToProcess.
  ///
  /// In en, this message translates to:
  /// **'Ready to process'**
  String get adminReadyToProcess;

  /// No description provided for @adminPackagesScanned.
  ///
  /// In en, this message translates to:
  /// **'Packages Scanned'**
  String get adminPackagesScanned;

  /// No description provided for @adminReadyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get adminReadyToScan;

  /// No description provided for @adminEnterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get adminEnterCodeManually;

  /// No description provided for @adminScanCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Code'**
  String get adminScanCode;

  /// No description provided for @adminScanWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Scan withdrawal'**
  String get adminScanWithdrawal;

  /// No description provided for @adminScanAndProcess.
  ///
  /// In en, this message translates to:
  /// **'Scan and process deliveries'**
  String get adminScanAndProcess;

  /// No description provided for @adminScanCodeToProcess.
  ///
  /// In en, this message translates to:
  /// **'Scan a code to process'**
  String get adminScanCodeToProcess;

  /// No description provided for @adminEboxCode.
  ///
  /// In en, this message translates to:
  /// **'Ebox Code'**
  String get adminEboxCode;

  /// No description provided for @adminNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get adminNoCategory;

  /// No description provided for @adminTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get adminTotalPrice;

  /// No description provided for @adminStoreDelivery.
  ///
  /// In en, this message translates to:
  /// **'Store Pickup'**
  String get adminStoreDelivery;

  /// No description provided for @adminHomeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Home Delivery'**
  String get adminHomeDelivery;

  /// No description provided for @adminPackageAlreadyScanned.
  ///
  /// In en, this message translates to:
  /// **'This package was already scanned'**
  String get adminPackageAlreadyScanned;

  /// No description provided for @adminPackageTypeMismatch.
  ///
  /// In en, this message translates to:
  /// **'This package is {packageType} type, but the scanned packages are {scannedType} type. You can only scan packages of the same delivery type.'**
  String adminPackageTypeMismatch(String packageType, String scannedType);

  /// No description provided for @adminReceptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Package Reception'**
  String get adminReceptionTitle;

  /// No description provided for @adminEnterEboxManually.
  ///
  /// In en, this message translates to:
  /// **'Enter ebox code manually'**
  String get adminEnterEboxManually;

  /// No description provided for @adminScanEboxHint.
  ///
  /// In en, this message translates to:
  /// **'Scan the ebox code of a package'**
  String get adminScanEboxHint;

  /// No description provided for @adminScanEboxDesc.
  ///
  /// In en, this message translates to:
  /// **'The package will be validated and added to the list'**
  String get adminScanEboxDesc;

  /// No description provided for @adminReadyToReceive.
  ///
  /// In en, this message translates to:
  /// **'Ready to receive'**
  String get adminReadyToReceive;

  /// No description provided for @adminPackageAlreadyReceived.
  ///
  /// In en, this message translates to:
  /// **'This package was already received'**
  String get adminPackageAlreadyReceived;

  /// No description provided for @adminFinishReception.
  ///
  /// In en, this message translates to:
  /// **'Finish Reception'**
  String get adminFinishReception;

  /// No description provided for @adminFinishReceptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Packages will change to \"In Store\" status and will be assigned a rack automatically.'**
  String get adminFinishReceptionMessage;

  /// No description provided for @adminReceptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reception Successful'**
  String get adminReceptionSuccess;

  /// No description provided for @adminReceptionProcessError.
  ///
  /// In en, this message translates to:
  /// **'Error processing reception'**
  String get adminReceptionProcessError;

  /// No description provided for @adminConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get adminConfirm;

  /// No description provided for @adminDispatchHome.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Home Delivery'**
  String get adminDispatchHome;

  /// No description provided for @adminShippingProvider.
  ///
  /// In en, this message translates to:
  /// **'Shipping Provider'**
  String get adminShippingProvider;

  /// No description provided for @adminConfirmDispatch.
  ///
  /// In en, this message translates to:
  /// **'Confirm Dispatch'**
  String get adminConfirmDispatch;

  /// No description provided for @adminProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get adminProcessing;

  /// No description provided for @adminScanPackagesToDispatch.
  ///
  /// In en, this message translates to:
  /// **'Scan packages to dispatch'**
  String get adminScanPackagesToDispatch;

  /// No description provided for @adminGeneralSummary.
  ///
  /// In en, this message translates to:
  /// **'General Summary'**
  String get adminGeneralSummary;

  /// No description provided for @adminPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get adminPackages;

  /// No description provided for @adminProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProducts;

  /// No description provided for @adminWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get adminWeight;

  /// No description provided for @adminTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Weight'**
  String get adminTotalWeight;

  /// No description provided for @adminProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get adminProvider;

  /// No description provided for @adminTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get adminTransport;

  /// No description provided for @adminPackageTotal.
  ///
  /// In en, this message translates to:
  /// **'Package Total'**
  String get adminPackageTotal;

  /// No description provided for @adminSelectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select a provider'**
  String get adminSelectProvider;

  /// No description provided for @adminScanAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'You must scan at least one package'**
  String get adminScanAtLeastOne;

  /// No description provided for @adminDispatchError.
  ///
  /// In en, this message translates to:
  /// **'Error processing dispatch'**
  String get adminDispatchError;

  /// No description provided for @adminDispatchSuccess.
  ///
  /// In en, this message translates to:
  /// **'Dispatch created successfully!'**
  String get adminDispatchSuccess;

  /// No description provided for @adminErrorLoadingProviders.
  ///
  /// In en, this message translates to:
  /// **'Error loading providers'**
  String get adminErrorLoadingProviders;

  /// No description provided for @adminRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get adminRequired;

  /// No description provided for @adminProcessDelivery.
  ///
  /// In en, this message translates to:
  /// **'Process Delivery'**
  String get adminProcessDelivery;

  /// No description provided for @adminConfirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get adminConfirmDelivery;

  /// No description provided for @adminCaptureSignature.
  ///
  /// In en, this message translates to:
  /// **'You must capture the customer signature'**
  String get adminCaptureSignature;

  /// No description provided for @adminSelectRecipient.
  ///
  /// In en, this message translates to:
  /// **'You must select who receives the package'**
  String get adminSelectRecipient;

  /// No description provided for @adminEnterManagerName.
  ///
  /// In en, this message translates to:
  /// **'You must enter the manager name'**
  String get adminEnterManagerName;

  /// No description provided for @adminSignatureError.
  ///
  /// In en, this message translates to:
  /// **'Error capturing signature'**
  String get adminSignatureError;

  /// No description provided for @adminDeliveryError.
  ///
  /// In en, this message translates to:
  /// **'Error processing delivery'**
  String get adminDeliveryError;

  /// No description provided for @adminEditLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get adminEditLocation;

  /// No description provided for @adminWarehouseLocation.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Location'**
  String get adminWarehouseLocation;

  /// No description provided for @adminSelectRackSegment.
  ///
  /// In en, this message translates to:
  /// **'Select a rack to see available segments'**
  String get adminSelectRackSegment;

  /// No description provided for @adminScanningRack.
  ///
  /// In en, this message translates to:
  /// **'Scanning Rack'**
  String get adminScanningRack;

  /// No description provided for @adminScanningSegment.
  ///
  /// In en, this message translates to:
  /// **'Scanning Segment'**
  String get adminScanningSegment;

  /// No description provided for @adminLocationUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Location will be updated immediately after saving'**
  String get adminLocationUpdateMessage;

  /// No description provided for @adminSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get adminSaving;

  /// No description provided for @adminSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get adminSaveLocation;

  /// No description provided for @adminSelectRack.
  ///
  /// In en, this message translates to:
  /// **'Select Rack'**
  String get adminSelectRack;

  /// No description provided for @adminScanRack.
  ///
  /// In en, this message translates to:
  /// **'Scan Rack'**
  String get adminScanRack;

  /// No description provided for @adminSelectSegment.
  ///
  /// In en, this message translates to:
  /// **'Select Segment'**
  String get adminSelectSegment;

  /// No description provided for @adminOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get adminOccupied;

  /// No description provided for @adminScanSegment.
  ///
  /// In en, this message translates to:
  /// **'Scan Segment'**
  String get adminScanSegment;

  /// No description provided for @adminLocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated successfully'**
  String get adminLocationUpdated;

  /// No description provided for @adminLockerPickup.
  ///
  /// In en, this message translates to:
  /// **'Store pickup'**
  String get adminLockerPickup;

  /// No description provided for @adminCreatePickup.
  ///
  /// In en, this message translates to:
  /// **'Create pickup'**
  String get adminCreatePickup;

  /// No description provided for @adminCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get adminCreating;

  /// No description provided for @adminErrorLoadingStores.
  ///
  /// In en, this message translates to:
  /// **'Error loading stores'**
  String get adminErrorLoadingStores;

  /// No description provided for @adminSelectStoreFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a store first'**
  String get adminSelectStoreFirst;

  /// No description provided for @adminPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminPending;

  /// No description provided for @adminDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get adminDelivered;

  /// No description provided for @adminScanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get adminScanQR;

  /// No description provided for @adminSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get adminSearch;

  /// No description provided for @adminReintentar.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminReintentar;

  /// No description provided for @adminNoPendingPickups.
  ///
  /// In en, this message translates to:
  /// **'No pending pickups'**
  String get adminNoPendingPickups;

  /// No description provided for @adminNoDeliveries.
  ///
  /// In en, this message translates to:
  /// **'No deliveries registered'**
  String get adminNoDeliveries;

  /// No description provided for @adminPhysicalLocker.
  ///
  /// In en, this message translates to:
  /// **'Physical locker'**
  String get adminPhysicalLocker;

  /// No description provided for @adminLockerAccount.
  ///
  /// In en, this message translates to:
  /// **'Locker account'**
  String get adminLockerAccount;

  /// No description provided for @adminType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get adminType;

  /// No description provided for @adminPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get adminPackage;

  /// No description provided for @adminCorrespondence.
  ///
  /// In en, this message translates to:
  /// **'Correspondence'**
  String get adminCorrespondence;

  /// No description provided for @adminScanQRPasteToken.
  ///
  /// In en, this message translates to:
  /// **'Scan QR or paste token'**
  String get adminScanQRPasteToken;

  /// No description provided for @adminPasteTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Paste token or email URL'**
  String get adminPasteTokenHint;

  /// No description provided for @adminSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get adminSearching;

  /// No description provided for @adminContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get adminContinue;

  /// No description provided for @adminDeliveryRegistered.
  ///
  /// In en, this message translates to:
  /// **'Delivery registered successfully'**
  String get adminDeliveryRegistered;

  /// No description provided for @adminPickupDetail.
  ///
  /// In en, this message translates to:
  /// **'Pickup detail'**
  String get adminPickupDetail;

  /// No description provided for @adminClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get adminClient;

  /// No description provided for @adminPieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get adminPieces;

  /// No description provided for @adminPinExpires.
  ///
  /// In en, this message translates to:
  /// **'PIN expires'**
  String get adminPinExpires;

  /// No description provided for @adminDelivering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get adminDelivering;

  /// No description provided for @adminDeliver.
  ///
  /// In en, this message translates to:
  /// **'Deliver'**
  String get adminDeliver;

  /// No description provided for @adminSearchLockerCode.
  ///
  /// In en, this message translates to:
  /// **'Enter locker code or DUI and press Search'**
  String get adminSearchLockerCode;

  /// No description provided for @adminNoStoresAssigned.
  ///
  /// In en, this message translates to:
  /// **'You have no stores assigned'**
  String get adminNoStoresAssigned;

  /// No description provided for @adminErrorLoadingLockers.
  ///
  /// In en, this message translates to:
  /// **'Error loading lockers'**
  String get adminErrorLoadingLockers;

  /// No description provided for @adminErrorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts'**
  String get adminErrorLoadingAccounts;

  /// No description provided for @adminCompleteStoreLockerAccount.
  ///
  /// In en, this message translates to:
  /// **'Complete store, locker and account'**
  String get adminCompleteStoreLockerAccount;

  /// No description provided for @adminNoStoresAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stores available'**
  String get adminNoStoresAvailable;

  /// No description provided for @adminPinClient.
  ///
  /// In en, this message translates to:
  /// **'Client PIN (6 digits)'**
  String get adminPinClient;

  /// No description provided for @adminEnterPin6.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit PIN'**
  String get adminEnterPin6;

  /// No description provided for @adminDeliveryRegisterError.
  ///
  /// In en, this message translates to:
  /// **'Error registering delivery. Try again.'**
  String get adminDeliveryRegisterError;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
