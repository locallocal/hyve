import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/core/widgets/common.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/chat/views/chat.dart';
import 'package:hyve/ui/features/chats/views/chat_item.dart';
import 'package:hyve/ui/features/projects/views/project_workspace_page.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/utils/utils.dart';
import 'package:hyve/utils/time.dart';
import 'package:hyve/utils/theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatListBuilder extends StatelessWidget {
  final List<ProjectWorkspace> projects;
  final String? selectedChatId;
  final bool selectionVisible;
  final bool showExecutionStatus;
  final ValueChanged<String> onChatDeleted;
  final ValueChanged<ProjectWorkspace> onProjectSelected;
  final Future<void> Function(String chatId) onDeleteChat;

  const ChatListBuilder({
    super.key,
    required this.projects,
    this.selectedChatId,
    this.selectionVisible = true,
    this.showExecutionStatus = true,
    required this.onChatDeleted,
    required this.onProjectSelected,
    required this.onDeleteChat,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopPlatform(context);
    return ListView.separated(
      padding: EdgeInsets.only(bottom: isDesktop ? 8 : 0),
      itemCount: projects.length,
      separatorBuilder: (context, index) => SizedBox(height: isDesktop ? 8 : 0),
      itemBuilder: (context, index) {
        final project = projects[index];
        final chat = project.chat;
        final bot = project.firstBot;
        void openChat({bool refreshAfterClose = false}) {
          if (isDesktop) {
            onProjectSelected(project);
            return;
          }

          final navigation = Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) =>
                      project.usesProjectAgentRuntime
                          ? ProjectWorkspacePage(
                            projectId: project.id,
                            projectName: project.name,
                          )
                          : ChatPage(
                            id: chat.id,
                            bot: bot!,
                            bots: project.bots,
                            projectName: project.name,
                            showExecutionStatus: showExecutionStatus,
                          ),
            ),
          );
          if (refreshAfterClose) {
            navigation.then((_) => onChatDeleted(''));
          }
        }

        Future<void> deleteChat() async {
          final baseDescription = S.of(context).confirmDeleteChat(project.name);
          final deleteDescription =
              project.usesProjectAgentRuntime
                  ? '$baseDescription\n\n${ProjectLocalizations.of(context).isChinese ? '不会删除智能体、技能、配置或长期记忆。' : 'Agents, skills, configuration, and long-term memory are not deleted.'}'
                  : baseDescription;
          final confirm =
              isDesktop
                  ? await showChatShadDialog<bool>(
                    context: context,
                    variant: ShadDialogVariant.alert,
                    builder:
                        (dialogContext) => ShadDialog.alert(
                          title: Text(
                            desktopProjectText(
                              dialogContext,
                              S.of(dialogContext).deleteChat,
                            ),
                          ),
                          description: Text(
                            desktopProjectText(
                              dialogContext,
                              deleteDescription,
                            ),
                          ),
                          actions: [
                            ShadButton.outline(
                              onPressed:
                                  () => Navigator.pop(dialogContext, false),
                              child: Text(S.of(dialogContext).cancel),
                            ),
                            ShadButton.destructive(
                              onPressed:
                                  () => Navigator.pop(dialogContext, true),
                              child: Text(S.of(dialogContext).delete),
                            ),
                          ],
                        ),
                  )
                  : await showDialog<bool>(
                    context: context,
                    builder:
                        (dialogContext) => AlertDialog(
                          title: Center(
                            child: Text(
                              S.of(dialogContext).deleteChat,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    Theme.of(
                                      dialogContext,
                                    ).textTheme.bodyLarge?.fontSize,
                              ),
                            ),
                          ),
                          content: Text(deleteDescription),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, false),
                              child: Text(S.of(dialogContext).cancel),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(dialogContext, true),
                              child: Text(
                                S.of(dialogContext).delete,
                                style: TextStyle(
                                  color: HyveDesktopThemeSpec.error(
                                    dialogContext,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  );

          if (confirm != true || !context.mounted) return;
          try {
            await onDeleteChat(chat.id);
          } catch (error) {
            if (!context.mounted) return;
            final message = S
                .of(context)
                .deleteChatFailed(safeFailureMessage(context, error));
            showHyveNotice(
              context,
              message,
              tone: HyveNoticeTone.error,
              actionLabel: S.of(context).retry,
              onAction: deleteChat,
            );
            return;
          }

          if (!context.mounted) return;
          onChatDeleted(chat.id);
        }

        ChatListItem buildListItem({Widget? trailing}) {
          return ChatListItem(
            bot: bot,
            bots: project.bots,
            title: chat.name,
            isSelected:
                isDesktop && selectionVisible && selectedChatId == chat.id,
            lastMessage:
                chat.lastMessage.isEmpty
                    ? desktopProjectText(context, S.of(context).startChatting)
                    : chat.lastMessage.length > 25
                    ? '${chat.lastMessage.substring(0, 25)}...'
                    : chat.lastMessage,
            timestamp: formatTimestamp(context, chat.lastMessageTimestamp),
            trailing: trailing,
            onTap: () => openChat(refreshAfterClose: !isDesktop),
          );
        }

        if (isDesktop) {
          final contextItems = <Widget>[
            ShadContextMenuItem(
              leading: const Icon(desktopProjectIcon, size: 16),
              onPressed: openChat,
              child: Text(
                desktopProjectText(context, S.of(context).startChatting),
              ),
            ),
            const ShadSeparator.horizontal(
              margin: EdgeInsets.symmetric(vertical: 4),
            ),
            ShadContextMenuItem(
              leading: Icon(
                LucideIcons.trash2,
                size: 16,
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
              textStyle: TextStyle(
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
              onPressed: deleteChat,
              child: Text(S.of(context).delete),
            ),
          ];
          return HyveContextMenu(
            key: ValueKey('chat-menu-${chat.id}'),
            items: contextItems,
            child: buildListItem(
              trailing: _ChatRowActions(
                canOpen: true,
                onOpen: openChat,
                onDelete: deleteChat,
              ),
            ),
          );
        }

        return Slidable(
          key: Key(chat.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              CustomSlidableAction(
                onPressed: (_) => openChat(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble_rounded, size: 18),
              ),
              CustomSlidableAction(
                onPressed: (_) {},
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: const Icon(Icons.edit_square, size: 18),
              ),
              CustomSlidableAction(
                onPressed: (_) => deleteChat(),
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: const Icon(Icons.delete_rounded, size: 20),
              ),
            ],
          ),
          child: buildListItem(),
        );
      },
    );
  }
}

class _ChatRowActions extends StatefulWidget {
  const _ChatRowActions({
    required this.canOpen,
    required this.onOpen,
    required this.onDelete,
  });

  final bool canOpen;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  State<_ChatRowActions> createState() => _ChatRowActionsState();
}

class _ChatRowActionsState extends State<_ChatRowActions> {
  final ShadPopoverController _controller = ShadPopoverController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'chat-row-actions');
  bool _menuItemPressedWithPointer = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _invoke(VoidCallback action) {
    final shouldRestoreFocus =
        !_menuItemPressedWithPointer &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    _menuItemPressedWithPointer = false;
    _controller.hide();
    action();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (shouldRestoreFocus) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
  }

  void _toggleMenu() {
    if (!_controller.isOpen) {
      _menuItemPressedWithPointer = false;
    }
    _controller.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return ShadPopover(
      controller: _controller,
      popover:
          (context) => SizedBox(
            width: 184,
            child: Listener(
              onPointerDown: (_) => _menuItemPressedWithPointer = true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    enabled: widget.canOpen,
                    onPressed: () => _invoke(widget.onOpen),
                    mainAxisAlignment: MainAxisAlignment.start,
                    leading: const Icon(desktopProjectIcon, size: 16),
                    child: Text(
                      desktopProjectText(context, S.of(context).startChatting),
                    ),
                  ),
                  ShadButton.raw(
                    variant: ShadButtonVariant.ghost,
                    size: ShadButtonSize.sm,
                    foregroundColor: colors.destructive,
                    onPressed: () => _invoke(widget.onDelete),
                    mainAxisAlignment: MainAxisAlignment.start,
                    leading: const Icon(LucideIcons.trash2, size: 16),
                    child: Text(S.of(context).delete),
                  ),
                ],
              ),
            ),
          ),
      child: HyveDesktopIconAction(
        icon: LucideIcons.ellipsis,
        label: MaterialLocalizations.of(context).showMenuTooltip,
        focusNode: _focusNode,
        onPressed: _toggleMenu,
        hoverBackgroundColor: Colors.transparent,
      ),
    );
  }
}
