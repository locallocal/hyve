import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/widgets/logo.dart';
import 'package:hyve/utils/theme.dart';

class ChatListItem extends StatefulWidget {
  final Bot? bot;
  final List<Bot> bots;
  final String? title;
  final String lastMessage;
  final String timestamp;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const ChatListItem({
    super.key,
    this.bot,
    this.bots = const <Bot>[],
    this.title,
    required this.lastMessage,
    required this.timestamp,
    this.isSelected = false,
    required this.onTap,
    this.trailing,
  });

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  bool _trailingHovered = false;

  void _setTrailingHovered(bool hovered) {
    if (_trailingHovered == hovered) return;
    setState(() => _trailingHovered = hovered);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16;
    final selectedTextColor =
        widget.isSelected
            ? ShadTheme.of(context).colorScheme.primaryForeground
            : null;
    final titleStyle = HyveDesktopThemeSpec.bodyStyle(context)?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: (fontSize - 2).clamp(13, 14),
      color: selectedTextColor,
    );
    final metaStyle = HyveDesktopThemeSpec.metaStyle(context)?.copyWith(
      fontSize: (fontSize - 3).clamp(12, 13),
      color: selectedTextColor,
    );
    final provider = widget.bot?.provider ?? '';
    final subtitle =
        provider.isEmpty
            ? widget.lastMessage
            : '$provider · ${widget.lastMessage}';
    final timestamp = Text(widget.timestamp, style: metaStyle);
    final timestampWithTooltip =
        ShadTheme.maybeOf(context) == null
            ? Tooltip(message: widget.timestamp, child: timestamp)
            : ShadTooltip(
              builder: (context) => Text(widget.timestamp),
              child: timestamp,
            );

    return DesktopInteractiveListItem(
      selected: widget.isSelected,
      suppressHoverBackground: _trailingHovered,
      onTap: widget.onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 8, 10),
      child: Row(
        children: [
          _ProjectBotAvatars(
            bots:
                widget.bots.isEmpty && widget.bot != null
                    ? <Bot>[widget.bot!]
                    : widget.bots,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title?.trim().isNotEmpty == true
                            ? widget.title!.trim()
                            : widget.bot?.name ?? '',
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    timestampWithTooltip,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: metaStyle?.copyWith(
                    color:
                        widget.isSelected
                            ? ShadTheme.of(
                              context,
                            ).colorScheme.primaryForeground
                            : HyveDesktopThemeSpec.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 6),
            MouseRegion(
              onEnter: (_) => _setTrailingHovered(true),
              onExit: (_) => _setTrailingHovered(false),
              child: widget.trailing!,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectBotAvatars extends StatelessWidget {
  const _ProjectBotAvatars({required this.bots});

  final List<Bot> bots;

  @override
  Widget build(BuildContext context) {
    if (bots.isEmpty) {
      final shadScheme = ShadTheme.maybeOf(context)?.colorScheme;
      final materialScheme = Theme.of(context).colorScheme;
      return SizedBox.square(
        dimension: 32,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: shadScheme?.muted ?? materialScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.folder_outlined,
            size: 17,
            color:
                shadScheme?.mutedForeground ?? materialScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final visible = bots.take(3).toList(growable: false);
    final avatarSize = visible.length == 1 ? 32.0 : 26.0;
    final overlapOffset = visible.length == 1 ? 0.0 : 12.0;
    return Semantics(
      label: bots.map((bot) => bot.name).join(', '),
      child: SizedBox(
        width: avatarSize + overlapOffset * (visible.length - 1),
        height: 32,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            for (var index = visible.length - 1; index >= 0; index--)
              PositionedDirectional(
                start: overlapOffset * index,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: visible.length == 1 ? 0 : 2,
                    ),
                  ),
                  child: ShadAvatar(
                    visible[index].avatar.isEmpty
                        ? null
                        : File(visible[index].avatar),
                    size: Size.square(avatarSize),
                    backgroundColor:
                        visible[index].avatar.isEmpty
                            ? getFrostedProviderColor(
                              visible[index].provider,
                              Theme.of(context).colorScheme.primary,
                            )
                            : Theme.of(context).colorScheme.primary,
                    placeholder: buildProviderLogo(
                      context,
                      '',
                      visible[index].provider,
                      visible.length == 1 ? 16 : 13,
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
