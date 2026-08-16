part of 'new_project_page.dart';

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktopPlatform(context);
    final titleRow = Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
                desktop
                    ? HyveDesktopThemeSpec.sectionTitleStyle(context)?.copyWith(
                      fontSize:
                          HyveDesktopThemeSpec.botFormSectionTitleFontSize,
                    )
                    : Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [titleRow, const SizedBox(height: 14), child],
      );
    }
    final tokens = HyveDesktopTokens.of(context);
    return ShadCard(
      width: double.infinity,
      padding: const EdgeInsets.all(HyveDesktopThemeSpec.botFormSectionPadding),
      backgroundColor: tokens.raisedSurface,
      border: ShadBorder.all(
        color: tokens.separator,
        width: HyveDesktopThemeSpec.botFormSectionBorderWidth,
      ),
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: titleRow,
      child: Padding(padding: const EdgeInsets.only(top: 16), child: child),
    );
  }
}

class _ProjectBotChoice extends StatelessWidget {
  const _ProjectBotChoice({
    required this.bot,
    required this.desktop,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final Bot bot;
  final bool desktop;
  final bool selected;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      bot.provider.trim(),
      bot.model.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
    if (!desktop) {
      final hasAvatar = bot.avatar.isNotEmpty;
      return CheckboxListTile(
        key: ValueKey<String>('project-bot-${bot.id}'),
        value: selected,
        onChanged: enabled ? (_) => onChanged() : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        secondary: CircleAvatar(
          backgroundColor: getFrostedProviderColor(
            bot.provider,
            Theme.of(context).colorScheme.primary,
          ),
          backgroundImage: hasAvatar ? FileImage(File(bot.avatar)) : null,
          child:
              hasAvatar
                  ? null
                  : buildProviderLogo(context, '', bot.provider, 20),
        ),
        title: Text(
          bot.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            metadata.isEmpty
                ? null
                : Text(metadata, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }
    return Semantics(
      selected: selected,
      button: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: IgnorePointer(
          ignoring: !enabled,
          child: DesktopInteractiveListItem(
            key: ValueKey<String>('project-bot-${bot.id}'),
            selected: selected,
            onTap: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ShadAvatar(
                  bot.avatar.isEmpty ? null : File(bot.avatar),
                  size: const Size.square(40),
                  backgroundColor: getFrostedProviderColor(
                    bot.provider,
                    Theme.of(context).colorScheme.primary,
                  ),
                  placeholder: buildProviderLogo(context, '', bot.provider, 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (metadata.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          metadata,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HyveDesktopThemeSpec.metaStyle(context),
                        ),
                      ],
                    ],
                  ),
                ),
                Checkbox(
                  value: selected,
                  onChanged: enabled ? (_) => onChanged() : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
