import 'package:flutter/material.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';

/// Maps arbitrary failures to localized, product-safe copy. Raw exception
/// strings remain available only through [AppFailure.debugCause].
String safeFailureMessage(BuildContext context, Object error) {
  final failure = AppFailure.from(error);
  if (failure.code == 'bot_required_fields_missing') {
    return S.of(context).fillRequiredFields;
  }
  if (failure.code == 'database_downgrade_not_supported') {
    return '数据库由更高版本的 Stars 创建，请升级应用后再打开。';
  }
  if (failure.code == 'database_recovery_failed') {
    return '数据库完整性检查失败，且无法从当前版本备份恢复。';
  }
  return switch (failure.kind) {
    AppFailureKind.cancelled => S.of(context).replyCancelled,
    AppFailureKind.networkTimeout => S.of(context).statusTimedOut,
    _ => S.of(context).errorLoadingContent,
  };
}

/// Shows a floating informational message using the current Material shell.
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
    ),
  );
}

void showWarningSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: 16),
          Text(message),
        ],
      ),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

// 构建分组容器
Widget buildSectionContainer(
  BuildContext context,
  String title,
  List<Widget> children,
) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(24.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children
            .expand((child) => [child, const SizedBox(height: 4)])
            .take(children.length * 2 - 1),
      ],
    ),
  );
}

Widget buildCloseIcon(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.close_rounded,
      size: 16,
      color: Theme.of(context).colorScheme.secondary,
    ),
  );
}
