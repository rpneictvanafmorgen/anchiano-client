// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Anchiano';

  @override
  String get logout => 'Uitloggen';

  @override
  String get logoutButton => 'Uitloggen';

  @override
  String get languageSwitcherLabel => 'Taal';

  @override
  String get cancelButton => 'Annuleren';

  @override
  String get noData => 'Geen gegevens beschikbaar';

  @override
  String get loginTitle => 'Inloggen';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Wachtwoord';

  @override
  String get loginButton => 'Inloggen';

  @override
  String get loginRegisterLink => 'Nog geen account? Registreer';

  @override
  String get registerTitle => 'Account aanmaken';

  @override
  String get registerButton => 'Registreren';

  @override
  String get registerNameLabel => 'Naam';

  @override
  String get registerRepeatPasswordLabel => 'Herhaal wachtwoord';

  @override
  String get formErrorMissingFields => 'Vul alle verplichte velden in.';

  @override
  String get formErrorPasswordsNotMatching => 'Wachtwoorden komen niet overeen.';

  @override
  String get workspaceListTitle => 'Jouw werkruimtes';

  @override
  String get workspaceEmpty => 'Je bent nog geen lid van een workspace.';

  @override
  String get newWorkspaceTitle => 'Workspace aanmaken';

  @override
  String get newWorkspaceNameLabel => 'Naam van workspace';

  @override
  String get newWorkspaceCreateButton => 'Workspace aanmaken';

  @override
  String workspaceRoleLabel(Object role) {
    return 'Rol: $role';
  }

  @override
  String get workspaceRoleOwner => 'Eigenaar';

  @override
  String get workspaceRoleMember => 'Lid';

  @override
  String get workspaceRoleViewer => 'Kijker';

  @override
  String get workspaceMenuMembers => 'Leden';

  @override
  String get workspaceMenuRename => 'Hernoemen';

  @override
  String get workspaceMenuDelete => 'Verwijderen';

  @override
  String get workspaceRenameTitle => 'Workspace hernoemen';

  @override
  String get workspaceRenameNameLabel => 'Naam van workspace';

  @override
  String get workspaceRenameButton => 'Hernoemen';

  @override
  String get workspaceDeleteTitle => 'Workspace verwijderen';

  @override
  String workspaceDeleteMessage(Object name) {
    return 'Workspace \"$name\" verwijderen? Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get workspaceDeleteConfirmButton => 'Verwijderen';

  @override
  String get workspaceMembersTitle => 'Leden';

  @override
  String get workspaceMembersEmpty => 'Geen leden gevonden.';

  @override
  String get workspaceMembersAddTitle => 'Lid toevoegen';

  @override
  String get workspaceMembersEmailLabel => 'E-mailadres';

  @override
  String get workspaceMembersRoleLabel => 'Rol';

  @override
  String get workspaceMembersAddButton => 'Toevoegen';

  @override
  String get workspaceMembersRemoveTitle => 'Lid verwijderen';

  @override
  String workspaceMembersRemoveMessage(Object name) {
    return '$name verwijderen uit deze workspace?';
  }

  @override
  String get workspaceMembersRemoveConfirmButton => 'Verwijderen';

  @override
  String get taskListTitle => 'Taken';

  @override
  String get taskEmpty => 'Nog geen taken in deze workspace.';

  @override
  String get newTaskTitle => 'Nieuwe taak';

  @override
  String get newTaskNameLabel => 'Taaktitel';

  @override
  String get newTaskCreateButton => 'Taak aanmaken';

  @override
  String get taskDetailTitle => 'Taakdetails';

  @override
  String get taskFieldTitleLabel => 'Titel';

  @override
  String get taskFieldDescriptionLabel => 'Beschrijving';

  @override
  String get taskFieldStatusLabel => 'Status';

  @override
  String get taskFieldPriorityLabel => 'Prioriteit';

  @override
  String get taskFieldAssigneeLabel => 'Toegewezen aan';

  @override
  String get taskFieldDueDateLabel => 'Einddatum';

  @override
  String get taskSaveButton => 'Wijzigingen opslaan';

  @override
  String get taskAuditLogTitle => 'Wijzigingsgeschiedenis';

  @override
  String get taskAuditLogEmpty => 'Nog geen wijzigingen.';

  @override
  String taskAuditBy(Object actor) {
    return 'door $actor';
  }

  @override
  String get taskToggleCompleteButton => 'Markeer voltooid / onvoltooid';

  @override
  String get taskStatusOpen => 'Open';

  @override
  String get taskStatusInProgress => 'Bezig';

  @override
  String get taskStatusDone => 'Afgerond';

  @override
  String get taskPriorityLow => 'Laag';

  @override
  String get taskPriorityMedium => 'Middel';

  @override
  String get taskPriorityHigh => 'Hoog';

  @override
  String get authErrorLogin => 'Login mislukt.';

  @override
  String get authErrorRegister => 'Registratie mislukt.';

  @override
  String get workspaceErrorLoad => 'Kon workspaces niet ophalen.';

  @override
  String get workspaceErrorCreate => 'Kon workspace niet aanmaken.';

  @override
  String get workspaceErrorRename => 'Kon workspace niet hernoemen.';

  @override
  String get workspaceErrorDelete => 'Kon workspace niet verwijderen.';

  @override
  String get workspaceMembersErrorLoad => 'Kon members niet ophalen.';

  @override
  String get workspaceMembersErrorAdd => 'Kon member niet toevoegen.';

  @override
  String get workspaceMembersErrorUpdateRole => 'Kon rol niet aanpassen.';

  @override
  String get workspaceMembersErrorRemove => 'Kon member niet verwijderen.';

  @override
  String get taskErrorLoad => 'Kon taken niet ophalen.';

  @override
  String get taskErrorCreate => 'Kon taak niet aanmaken.';

  @override
  String get taskErrorDelete => 'Kon taak niet verwijderen.';

  @override
  String get taskDeleteButton => 'Verwijderen';

  @override
  String get taskDeleteTitle => 'Taak verwijderen';

  @override
  String taskDeleteMessage(Object title) {
    return 'Taak \"$title\" verwijderen? Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get taskDeleteConfirmButton => 'Verwijderen';

  @override
  String get workspaceReloadButton => 'Workspaces vernieuwen';

  @override
  String get taskReloadButton => 'Taken vernieuwen';

  @override
  String get taskSearchHint => 'Zoek taken...';

  @override
  String get taskClearSearch => 'Zoekopdracht wissen';

  @override
  String get taskFilterAll => 'Alles';

  @override
  String get taskFilterStatusLabel => 'Status';

  @override
  String get taskFilterPriorityLabel => 'Prioriteit';

  @override
  String get taskSortLabel => 'Sorteren op';

  @override
  String get taskSortTitle => 'Titel';

  @override
  String get taskSortStatus => 'Status';

  @override
  String get taskSortPriority => 'Prioriteit';

  @override
  String get taskSortAsc => 'Oplopend';

  @override
  String get taskSortDesc => 'Aflopend';

  @override
  String get taskFiltersReset => 'Reset';

  @override
  String get taskNoResults => 'Geen taken gevonden met deze filters.';
}
