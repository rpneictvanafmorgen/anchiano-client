import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Anchiano'**
  String get appTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @languageSwitcherLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSwitcherLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get loginRegisterLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerNameLabel;

  /// No description provided for @registerRepeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get registerRepeatPasswordLabel;

  /// No description provided for @formErrorMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get formErrorMissingFields;

  /// No description provided for @formErrorPasswordsNotMatching.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get formErrorPasswordsNotMatching;

  /// No description provided for @workspaceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workspaces'**
  String get workspaceListTitle;

  /// No description provided for @workspaceEmpty.
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any workspace yet.'**
  String get workspaceEmpty;

  /// No description provided for @newWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get newWorkspaceTitle;

  /// No description provided for @newWorkspaceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get newWorkspaceNameLabel;

  /// No description provided for @newWorkspaceCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get newWorkspaceCreateButton;

  /// No description provided for @workspaceRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String workspaceRoleLabel(Object role);

  /// No description provided for @workspaceRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get workspaceRoleOwner;

  /// No description provided for @workspaceRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get workspaceRoleMember;

  /// No description provided for @workspaceRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get workspaceRoleViewer;

  /// No description provided for @workspaceMenuMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get workspaceMenuMembers;

  /// No description provided for @workspaceMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get workspaceMenuRename;

  /// No description provided for @workspaceMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get workspaceMenuDelete;

  /// No description provided for @workspaceRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename workspace'**
  String get workspaceRenameTitle;

  /// No description provided for @workspaceRenameNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get workspaceRenameNameLabel;

  /// No description provided for @workspaceRenameButton.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get workspaceRenameButton;

  /// No description provided for @workspaceDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workspace'**
  String get workspaceDeleteTitle;

  /// No description provided for @workspaceDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete workspace \"{name}\"? This cannot be undone.'**
  String workspaceDeleteMessage(Object name);

  /// No description provided for @workspaceDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get workspaceDeleteConfirmButton;

  /// No description provided for @workspaceMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get workspaceMembersTitle;

  /// No description provided for @workspaceMembersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get workspaceMembersEmpty;

  /// No description provided for @workspaceMembersAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get workspaceMembersAddTitle;

  /// No description provided for @workspaceMembersEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get workspaceMembersEmailLabel;

  /// No description provided for @workspaceMembersRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get workspaceMembersRoleLabel;

  /// No description provided for @workspaceMembersAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get workspaceMembersAddButton;

  /// No description provided for @workspaceMembersRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get workspaceMembersRemoveTitle;

  /// No description provided for @workspaceMembersRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this workspace?'**
  String workspaceMembersRemoveMessage(Object name);

  /// No description provided for @workspaceMembersRemoveConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get workspaceMembersRemoveConfirmButton;

  /// No description provided for @taskListTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get taskListTitle;

  /// No description provided for @taskEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this workspace yet.'**
  String get taskEmpty;

  /// No description provided for @newTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskTitle;

  /// No description provided for @newTaskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get newTaskNameLabel;

  /// No description provided for @newTaskCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get newTaskCreateButton;

  /// No description provided for @taskDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetailTitle;

  /// No description provided for @taskFieldTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskFieldTitleLabel;

  /// No description provided for @taskFieldDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskFieldDescriptionLabel;

  /// No description provided for @taskFieldStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskFieldStatusLabel;

  /// No description provided for @taskFieldPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskFieldPriorityLabel;

  /// No description provided for @taskFieldAssigneeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get taskFieldAssigneeLabel;

  /// No description provided for @taskFieldDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskFieldDueDateLabel;

  /// No description provided for @taskSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get taskSaveButton;

  /// No description provided for @taskAuditLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get taskAuditLogTitle;

  /// No description provided for @taskAuditLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No changes yet.'**
  String get taskAuditLogEmpty;

  /// No description provided for @taskAuditBy.
  ///
  /// In en, this message translates to:
  /// **'by {actor}'**
  String taskAuditBy(Object actor);

  /// No description provided for @taskToggleCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Toggle completion'**
  String get taskToggleCompleteButton;

  /// No description provided for @taskStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get taskStatusOpen;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskStatusDone;

  /// No description provided for @taskPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLow;

  /// No description provided for @taskPriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get taskPriorityMedium;

  /// No description provided for @taskPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHigh;

  /// No description provided for @authErrorLogin.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get authErrorLogin;

  /// No description provided for @authErrorRegister.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get authErrorRegister;

  /// No description provided for @workspaceErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load workspaces.'**
  String get workspaceErrorLoad;

  /// No description provided for @workspaceErrorCreate.
  ///
  /// In en, this message translates to:
  /// **'Could not create workspace.'**
  String get workspaceErrorCreate;

  /// No description provided for @workspaceErrorRename.
  ///
  /// In en, this message translates to:
  /// **'Could not rename workspace.'**
  String get workspaceErrorRename;

  /// No description provided for @workspaceErrorDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete workspace.'**
  String get workspaceErrorDelete;

  /// No description provided for @workspaceMembersErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load members.'**
  String get workspaceMembersErrorLoad;

  /// No description provided for @workspaceMembersErrorAdd.
  ///
  /// In en, this message translates to:
  /// **'Could not add member.'**
  String get workspaceMembersErrorAdd;

  /// No description provided for @workspaceMembersErrorUpdateRole.
  ///
  /// In en, this message translates to:
  /// **'Could not update role.'**
  String get workspaceMembersErrorUpdateRole;

  /// No description provided for @workspaceMembersErrorRemove.
  ///
  /// In en, this message translates to:
  /// **'Could not remove member.'**
  String get workspaceMembersErrorRemove;

  /// No description provided for @taskErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load tasks.'**
  String get taskErrorLoad;

  /// No description provided for @taskErrorCreate.
  ///
  /// In en, this message translates to:
  /// **'Could not create task.'**
  String get taskErrorCreate;

  /// No description provided for @taskErrorDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete task.'**
  String get taskErrorDelete;

  /// No description provided for @taskDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskDeleteButton;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get taskDeleteTitle;

  /// No description provided for @taskDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete task \"{title}\"? This cannot be undone.'**
  String taskDeleteMessage(Object title);

  /// No description provided for @taskDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskDeleteConfirmButton;

  /// No description provided for @workspaceReloadButton.
  ///
  /// In en, this message translates to:
  /// **'Reload workspaces'**
  String get workspaceReloadButton;

  /// No description provided for @taskReloadButton.
  ///
  /// In en, this message translates to:
  /// **'Reload tasks'**
  String get taskReloadButton;

  /// No description provided for @taskSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get taskSearchHint;

  /// No description provided for @taskClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get taskClearSearch;

  /// No description provided for @taskFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get taskFilterAll;

  /// No description provided for @taskFilterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskFilterStatusLabel;

  /// No description provided for @taskFilterPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskFilterPriorityLabel;

  /// No description provided for @taskSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get taskSortLabel;

  /// No description provided for @taskSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskSortTitle;

  /// No description provided for @taskSortStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskSortStatus;

  /// No description provided for @taskSortPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskSortPriority;

  /// No description provided for @taskSortAsc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get taskSortAsc;

  /// No description provided for @taskSortDesc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get taskSortDesc;

  /// No description provided for @taskFiltersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get taskFiltersReset;

  /// No description provided for @taskNoResults.
  ///
  /// In en, this message translates to:
  /// **'No tasks match your filters.'**
  String get taskNoResults;

  /// No description provided for @taskAttachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get taskAttachmentsTitle;

  /// No description provided for @taskAttachmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attachments yet.'**
  String get taskAttachmentsEmpty;

  /// No description provided for @taskAttachmentUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload file'**
  String get taskAttachmentUploadButton;

  /// No description provided for @taskAttachmentUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get taskAttachmentUploading;

  /// No description provided for @taskAttachmentUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'File uploaded.'**
  String get taskAttachmentUploadSuccess;

  /// No description provided for @taskAttachmentPickError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get taskAttachmentPickError;

  /// No description provided for @taskAttachmentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete attachment'**
  String get taskAttachmentDeleteTitle;

  /// No description provided for @taskAttachmentDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String taskAttachmentDeleteMessage(String name);

  /// No description provided for @taskAttachmentDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskAttachmentDeleteConfirmButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'nl': return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
