import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

final class ProjectFileDropTarget extends StatefulWidget {
  const ProjectFileDropTarget({
    super.key,
    required this.onDropped,
    required this.idleLabel,
    required this.activeLabel,
    required this.child,
  });

  final ValueChanged<List<String>> onDropped;
  final String idleLabel;
  final String activeLabel;
  final Widget child;

  @override
  State<ProjectFileDropTarget> createState() => _ProjectFileDropTargetState();
}

final class _ProjectFileDropTargetState extends State<ProjectFileDropTarget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final activeColor =
        shadTheme?.colorScheme.primary ?? Theme.of(context).colorScheme.primary;
    final activeBackground =
        shadTheme?.colorScheme.accent ??
        Theme.of(context).colorScheme.primaryContainer;
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        widget.onDropped(<String>[for (final file in details.files) file.path]);
      },
      child: AnimatedContainer(
        key: const ValueKey<String>('artifact-drop-target'),
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _dragging ? activeBackground : null,
          border: Border.all(
            color: _dragging ? activeColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: shadTheme?.radius ?? BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            widget.child,
            PositionedDirectional(
              end: 12,
              bottom: 8,
              child: IgnorePointer(
                child: Semantics(
                  label: _dragging ? widget.activeLabel : widget.idleLabel,
                  liveRegion: _dragging,
                  child: ProjectBadge(
                    key: const ValueKey<String>('artifact-drop-hint'),
                    icon: LucideIcons.fileUp,
                    label: _dragging ? widget.activeLabel : widget.idleLabel,
                    variant:
                        _dragging
                            ? ProjectBadgeVariant.primary
                            : ProjectBadgeVariant.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
