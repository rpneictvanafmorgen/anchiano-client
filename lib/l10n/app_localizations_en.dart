// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Anchiano';

  @override
  String get logout => 'Logout';

  @override
  String get logoutButton => 'Log out';

  @override
  String get languageSwitcherLabel => 'Language';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get noData => 'No data available';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginRegisterLink => 'Don\'t have an account? Register';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerButton => 'Register';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerRepeatPasswordLabel => 'Repeat password';

  @override
  String get formErrorMissingFields => 'Please fill in all required fields.';

  @override
  String get formErrorPasswordsNotMatching => 'Passwords do not match.';

  @override
  String get workspaceListTitle => 'Your workspaces';

  @override
  String get workspaceEmpty => 'You are not a member of any workspace yet.';

  @override
  String get newWorkspaceTitle => 'Create workspace';

  @override
  String get newWorkspaceNameLabel => 'Workspace name';

  @override
  String get newWorkspaceCreateButton => 'Create workspace';

  @override
  String workspaceRoleLabel(Object role) {
    return 'Role: $role';
  }

  @override
  String get workspaceRoleOwner => 'Owner';

  @override
  String get workspaceRoleMember => 'Member';

  @override
  String get workspaceRoleViewer => 'Viewer';

  @override
  String get workspaceMenuMembers => 'Members';

  @override
  String get workspaceMenuRename => 'Rename';

  @override
  String get workspaceMenuDelete => 'Delete';

  @override
  String get workspaceRenameTitle => 'Rename workspace';

  @override
  String get workspaceRenameNameLabel => 'Workspace name';

  @override
  String get workspaceRenameButton => 'Rename';

  @override
  String get workspaceDeleteTitle => 'Delete workspace';

  @override
  String workspaceDeleteMessage(Object name) {
    return 'Delete workspace \"$name\"? This cannot be undone.';
  }

  @override
  String get workspaceDeleteConfirmButton => 'Delete';

  @override
  String get workspaceMembersTitle => 'Members';

  @override
  String get workspaceMembersEmpty => 'No members found.';

  @override
  String get workspaceMembersAddTitle => 'Add member';

  @override
  String get workspaceMembersEmailLabel => 'Email address';

  @override
  String get workspaceMembersRoleLabel => 'Role';

  @override
  String get workspaceMembersAddButton => 'Add';

  @override
  String get workspaceMembersRemoveTitle => 'Remove member';

  @override
  String workspaceMembersRemoveMessage(Object name) {
    return 'Remove $name from this workspace?';
  }

  @override
  String get workspaceMembersRemoveConfirmButton => 'Remove';

  @override
  String get taskListTitle => 'Tasks';

  @override
  String get taskEmpty => 'No tasks in this workspace yet.';

  @override
  String get newTaskTitle => 'New task';

  @override
  String get newTaskNameLabel => 'Task title';

  @override
  String get newTaskCreateButton => 'Create task';

  @override
  String get taskDetailTitle => 'Task details';

  @override
  String get taskFieldTitleLabel => 'Title';

  @override
  String get taskFieldDescriptionLabel => 'Description';

  @override
  String get taskFieldStatusLabel => 'Status';

  @override
  String get taskFieldPriorityLabel => 'Priority';

  @override
  String get taskFieldAssigneeLabel => 'Assignee';

  @override
  String get taskFieldDueDateLabel => 'Due date';

  @override
  String get taskSaveButton => 'Save changes';

  @override
  String get taskAuditLogTitle => 'Change history';

  @override
  String get taskAuditLogEmpty => 'No changes yet.';

  @override
  String taskAuditBy(Object actor) {
    return 'by $actor';
  }

  @override
  String get taskToggleCompleteButton => 'Toggle completion';

  @override
  String get taskStatusOpen => 'Open';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusDone => 'Done';

  @override
  String get taskPriorityLow => 'Low';

  @override
  String get taskPriorityMedium => 'Medium';

  @override
  String get taskPriorityHigh => 'High';

  @override
  String get authErrorLogin => 'Login failed.';

  @override
  String get authErrorRegister => 'Registration failed.';

  @override
  String get workspaceErrorLoad => 'Could not load workspaces.';

  @override
  String get workspaceErrorCreate => 'Could not create workspace.';

  @override
  String get workspaceErrorRename => 'Could not rename workspace.';

  @override
  String get workspaceErrorDelete => 'Could not delete workspace.';

  @override
  String get workspaceMembersErrorLoad => 'Could not load members.';

  @override
  String get workspaceMembersErrorAdd => 'Could not add member.';

  @override
  String get workspaceMembersErrorUpdateRole => 'Could not update role.';

  @override
  String get workspaceMembersErrorRemove => 'Could not remove member.';

  @override
  String get taskErrorLoad => 'Could not load tasks.';

  @override
  String get taskErrorCreate => 'Could not create task.';

  @override
  String get taskErrorDelete => 'Could not delete task.';

  @override
  String get taskDeleteButton => 'Delete';

  @override
  String get taskDeleteTitle => 'Delete task';

  @override
  String taskDeleteMessage(Object title) {
    return 'Delete task \"$title\"? This cannot be undone.';
  }

  @override
  String get taskDeleteConfirmButton => 'Delete';

  @override
  String get workspaceReloadButton => 'Reload workspaces';

  @override
  String get taskReloadButton => 'Reload tasks';

  @override
  String get taskSearchHint => 'Search tasks...';

  @override
  String get taskClearSearch => 'Clear search';

  @override
  String get taskFilterAll => 'All';

  @override
  String get taskFilterStatusLabel => 'Status';

  @override
  String get taskFilterPriorityLabel => 'Priority';

  @override
  String get taskSortLabel => 'Sort by';

  @override
  String get taskSortTitle => 'Title';

  @override
  String get taskSortStatus => 'Status';

  @override
  String get taskSortPriority => 'Priority';

  @override
  String get taskSortAsc => 'Ascending';

  @override
  String get taskSortDesc => 'Descending';

  @override
  String get taskFiltersReset => 'Reset';

  @override
  String get taskNoResults => 'No tasks match your filters.';

  @override
  String get taskAttachmentsTitle => 'Attachments';

  @override
  String get taskAttachmentsEmpty => 'No attachments yet.';

  @override
  String get taskAttachmentUploadButton => 'Upload file';

  @override
  String get taskAttachmentUploading => 'Uploading...';

  @override
  String get taskAttachmentUploadSuccess => 'File uploaded.';

  @override
  String get taskAttachmentPickError => 'Could not read the selected file.';

  @override
  String get taskAttachmentDeleteTitle => 'Delete attachment';

  @override
  String taskAttachmentDeleteMessage(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get taskAttachmentDeleteConfirmButton => 'Delete';

  @override
  String get taskAttachmentOpenButton => 'Open';
}
