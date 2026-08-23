import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/utils/utils.dart';

/// Shows the confirmation used before abandoning an active generation.
Future<bool> showStopGenerationBeforeLeavingDialog(BuildContext context) async {
  final result = await showChatShadDialog<bool>(
    context: context,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    variant: ShadDialogVariant.alert,
    builder:
        (dialogContext) => ShadDialog.alert(
          title: Text(
            desktopProjectText(
              dialogContext,
              S.of(dialogContext).stopGenerationBeforeLeaving,
            ),
          ),
          description: Text(
            desktopProjectText(
              dialogContext,
              S.of(dialogContext).stopGenerationBeforeLeavingDescription,
            ),
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(S.of(dialogContext).cancel),
            ),
            ShadButton.destructive(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(S.of(dialogContext).stopAndContinue),
            ),
          ],
        ),
  );

  return result ?? false;
}
