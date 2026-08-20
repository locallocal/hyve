import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/dependency_injection/app_scope.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/core/widgets/common.dart';
import 'package:hyve/ui/features/chats/view_models/chat_list_view_model.dart';
import 'package:hyve/ui/features/chats/views/chat_list_builder.dart';
import 'package:hyve/ui/features/chats/views/new_project_page.dart';
import 'package:hyve/ui/features/projects/views/project_workspace_page.dart';
import 'package:hyve/utils/theme.dart';
import 'package:hyve/utils/utils.dart';

class ChatListPage extends StatefulWidget {
  final String? selectedChatId;
  final ValueChanged<ProjectWorkspace> onProjectSelected;
  final VoidCallback? onSelectionCleared;
  final bool sidebarMode;
  final bool selectionVisible;
  final bool showExecutionStatus;
  final ChatListViewModel viewModel;
  const ChatListPage({
    super.key,
    required this.viewModel,
    this.selectedChatId,
    required this.onProjectSelected,
    this.onSelectionCleared,
    this.sidebarMode = false,
    this.selectionVisible = true,
    this.showExecutionStatus = true,
  });

  @override
  State<ChatListPage> createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Chat> get chatList => widget.viewModel.chats;
  List<Chat> get filteredChatList => widget.viewModel.filteredChats;
  List<ProjectWorkspace> get projects => widget.viewModel.projects;
  List<ProjectWorkspace> get filteredProjects =>
      widget.viewModel.filteredProjects;
  List<Bot> get bots => widget.viewModel.bots;
  bool get isLoading => widget.viewModel.isLoading;
  String? get loadError =>
      widget.viewModel.error == null
          ? null
          : safeFailureMessage(context, widget.viewModel.error!);
  String get searchQuery => widget.viewModel.query;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void focusSearch() => _searchFocusNode.requestFocus();

  Future<void> openNewProjectPage() => _openNewProjectPage();

  Future<void> _loadChatList() => widget.viewModel.load();

  void _filterChats(String query) => widget.viewModel.search(query);

  void _clearSearch() {
    _searchController.clear();
    _filterChats('');
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final isDesktop = isDesktopPlatform(context);
    final fontSize = Theme.of(context).textTheme.bodyLarge?.fontSize;
    final body =
        isLoading
            ? _buildLoadingState(isDesktop)
            : loadError != null
            ? _buildErrorState(isDesktop)
            : _buildListSection(isDesktop);

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            S.of(context).chats,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          scrolledUnderElevation: 0,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: S.of(context).newChat,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(48),
                maximumSize: const Size.square(48),
              ),
              icon: Icon(
                Icons.add_circle_rounded,
                semanticLabel: S.of(context).newChat,
              ),
              onPressed: _openNewProjectPage,
            ),
          ],
        ),
        body: body,
      );
    }

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _searchFocusNode.hasFocus &&
            searchQuery.isNotEmpty) {
          _clearSearch();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: DesktopListPanel(
        title: '',
        description: '',
        searchHintText: S.of(context).searchChats,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onSearchChanged: _filterChats,
        showHeader: !widget.sidebarMode,
        action:
            widget.sidebarMode
                ? const SizedBox.shrink()
                : ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: _openNewProjectPage,
                  height: HyveDesktopThemeSpec.botFormFieldHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: const Icon(desktopProjectIcon, size: 16),
                  child: Text(
                    desktopProjectText(context, S.of(context).newChat),
                  ),
                ),
        child: body,
      ),
    );
  }

  Widget _buildLoadingState(bool isDesktop) => Center(
    child:
        isDesktop
            ? const SizedBox(width: 120, child: ShadProgress())
            : const CircularProgressIndicator(),
  );

  Widget _buildErrorState(bool isDesktop) {
    if (!isDesktop) {
      return Center(
        child: TextButton(
          onPressed: _loadChatList,
          child: Text(S.of(context).retry),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: ShadAlert.destructive(
          icon: const Icon(LucideIcons.circleAlert),
          title: Text(
            desktopProjectText(context, S.of(context).unableToLoadChats),
          ),
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loadError ?? ''),
              const SizedBox(height: 12),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: _loadChatList,
                leading: const Icon(LucideIcons.refreshCw, size: 16),
                child: Text(S.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(bool isDesktop) {
    if (filteredChatList.isEmpty) {
      return _buildEmptyChatsView(isDesktop);
    }

    return ChatListBuilder(
      projects: filteredProjects,
      selectedChatId: widget.selectedChatId,
      selectionVisible: widget.selectionVisible,
      showExecutionStatus: widget.showExecutionStatus,
      onDeleteChat: widget.viewModel.deleteChat,
      onChatDeleted: (String id) {
        if (id.isNotEmpty) {
          final wasSelected = widget.selectedChatId == id;
          final deletedIndex = chatList.indexWhere((chat) => chat.id == id);
          final remainingChats = chatList
              .where((chat) => chat.id != id)
              .toList(growable: false);
          if (wasSelected) {
            if (remainingChats.isEmpty) {
              widget.onSelectionCleared?.call();
            } else {
              final adjacentIndex =
                  deletedIndex.clamp(0, remainingChats.length - 1).toInt();
              final adjacentChat = remainingChats[adjacentIndex];
              final adjacentProject = projects
                  .cast<ProjectWorkspace?>()
                  .firstWhere(
                    (project) => project?.id == adjacentChat.id,
                    orElse: () => null,
                  );
              if (adjacentProject == null) {
                widget.onSelectionCleared?.call();
              } else {
                widget.onProjectSelected(adjacentProject);
              }
            }
          }
        } else {
          _loadChatList();
        }
      },
      onProjectSelected: widget.onProjectSelected,
    );
  }

  Widget _buildEmptyChatsView(bool isDesktop) {
    if (isDesktop) {
      return DesktopEmptyStateCard(
        icon: searchQuery.isNotEmpty ? LucideIcons.searchX : desktopProjectIcon,
        title: desktopProjectText(
          context,
          searchQuery.isNotEmpty
              ? S.of(context).noMatchingChats
              : S.of(context).noChats,
        ),
        description:
            searchQuery.isNotEmpty
                ? S.of(context).tryDifferentSearch
                : desktopProjectText(context, S.of(context).clickToStartChat),
        supportingText:
            searchQuery.isNotEmpty ? S.of(context).chatSearchScope : null,
        action:
            searchQuery.isEmpty
                ? null
                : ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: _clearSearch,
                  height: HyveDesktopThemeSpec.controlHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: const Icon(LucideIcons.x, size: 16),
                  child: Text(S.of(context).clearSearch),
                ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (searchQuery.isNotEmpty)
                Text(
                  S.of(context).noMatchingChats,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
              else
                Image.asset(
                  'assets/images/profile/no_chats_v2.png',
                  width: 256,
                  height: 256,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              Text(
                S.of(context).noChats,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).clickToStartChat,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openNewProjectPage,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(S.of(context).newChat),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNewProjectPage() async {
    if (!mounted) return;
    final desktop = isDesktopPlatform(context);
    final viewModel = AppScope.of(context).createNewProjectViewModel();
    final result =
        desktop
            ? await showShadDialog<ProjectWorkspace>(
              context: context,
              barrierDismissible: false,
              builder: (context) => NewProjectPage(viewModel: viewModel),
            )
            : await showDialog<ProjectWorkspace>(
              context: context,
              builder: (context) => NewProjectPage(viewModel: viewModel),
            );
    if (!mounted || result == null) return;
    await _loadChatList();
    if (!mounted) return;
    widget.onProjectSelected(result);
    if (isDesktopPlatform(context)) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder:
            (context) => ProjectWorkspacePage(
              projectId: result.id,
              projectName: result.name,
            ),
      ),
    );
  }
}
