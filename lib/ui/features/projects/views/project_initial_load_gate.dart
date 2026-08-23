import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

/// Prevents an asynchronous page from rendering its empty state before the
/// first data snapshot is ready.
final class ProjectInitialLoadGate extends StatelessWidget {
  const ProjectInitialLoadGate({
    super.key,
    required this.ready,
    required this.loadingLabel,
    required this.child,
  });

  final bool ready;
  final String loadingLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (ready) return child;
    return Semantics(
      key: const ValueKey<String>('project-workspace-loading'),
      container: true,
      label: loadingLabel,
      child: ExcludeSemantics(
        child: Center(
          child:
              hasShadProjectTheme(context)
                  ? const SizedBox(width: 120, child: ShadProgress())
                  : const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
        ),
      ),
    );
  }
}
