import 'package:flutter/material.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';

final class ToolApprovalCard extends StatelessWidget {
  const ToolApprovalCard({
    super.key,
    required this.request,
    required this.onDecision,
    this.desktopMode = false,
  });

  final ToolApprovalRequest request;
  final ValueChanged<ToolApprovalDecision> onDecision;
  final bool desktopMode;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final toolTitle =
        request.definition.title.trim().isEmpty
            ? request.definition.name
            : request.definition.title;
    final argumentSummary = request.call.arguments.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
    return Semantics(
      container: true,
      liveRegion: true,
      label:
          '${strings.toolCalls}: $toolTitle, '
          '${request.definition.riskLevel.name}',
      child: Container(
        key: const ValueKey<String>('tool-approval-card'),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(desktopMode ? 10 : 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gpp_maybe_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    toolTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  request.definition.riskLevel.name,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.definition.description),
            if (argumentSummary.isNotEmpty) ...[
              const SizedBox(height: 6),
              SelectableText(
                argumentSummary,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  key: const ValueKey<String>('deny-tool-call'),
                  onPressed: () => onDecision(ToolApprovalDecision.deny),
                  child: Text(strings.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const ValueKey<String>('approve-tool-call'),
                  onPressed: () => onDecision(ToolApprovalDecision.allowOnce),
                  child: Text(strings.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
