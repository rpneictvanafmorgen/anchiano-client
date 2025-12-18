import 'package:anchiano_client/l10n/app_localizations.dart';

String localizedStatus(AppLocalizations t, String backendStatus) {
  switch (backendStatus.toUpperCase()) {
    case 'OPEN':
      return t.taskStatusOpen;
    case 'IN_PROGRESS':
      return t.taskStatusInProgress;
    case 'DONE':
      return t.taskStatusDone;
    default:
      return backendStatus;
  }
}

String localizedPriority(AppLocalizations t, String backendPriority) {
  switch (backendPriority.toUpperCase()) {
    case 'LOW':
      return t.taskPriorityLow;
    case 'MEDIUM':
      return t.taskPriorityMedium;
    case 'HIGH':
      return t.taskPriorityHigh;
    default:
      return backendPriority;
  }
}

String localizedAuditStatus(AppLocalizations t, String raw) {
  switch (raw) {
    case 'OPEN':
      return t.taskStatusOpen;
    case 'IN_PROGRESS':
      return t.taskStatusInProgress;
    case 'DONE':
      return t.taskStatusDone;
    default:
      return raw;
  }
}

String localizedAuditPriority(AppLocalizations t, String raw) {
  switch (raw) {
    case 'LOW':
      return t.taskPriorityLow;
    case 'MEDIUM':
      return t.taskPriorityMedium;
    case 'HIGH':
      return t.taskPriorityHigh;
    default:
      return raw;
  }
}

