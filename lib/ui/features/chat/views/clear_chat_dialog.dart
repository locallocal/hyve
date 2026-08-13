import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:stars/utils/utils.dart';

/// 显示清除聊天历史对话框
Future<bool> showClearChatDialog(BuildContext context, String botName) async {
  if (isDesktopPlatform(context)) {
    return _showDesktopConversationConfirmation(
      context: context,
      title: S.of(context).clearChatHistory,
      description: S.of(context).confirmClearChat(botName),
      confirmLabel: S.of(context).clear,
    );
  }

  final result = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Center(
            child: Text(
              S.of(context).clearChatHistory,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),
          content: Text(S.of(context).confirmClearChat(botName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                S.of(context).clear,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
  );

  return result ?? false;
}

/// Shows the confirmation used before abandoning an active generation.
///
/// This intentionally shares the desktop conversation confirmation styling
/// used by [showClearChatDialog].
Future<bool> showStopGenerationBeforeLeavingDialog(BuildContext context) async {
  return _showDesktopConversationConfirmation(
    context: context,
    title: S.of(context).stopGenerationBeforeLeaving,
    description: S.of(context).stopGenerationBeforeLeavingDescription,
    confirmLabel: S.of(context).stopAndContinue,
  );
}

Future<bool> _showDesktopConversationConfirmation({
  required BuildContext context,
  required String title,
  required String description,
  required String confirmLabel,
}) async {
  final result = await showChatShadDialog<bool>(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    variant: ShadDialogVariant.alert,
    builder:
        (dialogContext) => ShadDialog.alert(
          title: Text(desktopConversationText(dialogContext, title)),
          description: Text(
            desktopConversationText(dialogContext, description),
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(S.of(dialogContext).cancel),
            ),
            ShadButton.destructive(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
  );

  return result ?? false;
}
