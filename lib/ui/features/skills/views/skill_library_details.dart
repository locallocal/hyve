part of 'skill_library.dart';

class _SkillDetailsDialog extends StatefulWidget {
  const _SkillDetailsDialog({
    required this.content,
    required this.onUpdatePolicyChanged,
    required this.onCopyStorageLocation,
  });

  final SkillContent content;
  final Future<void> Function(SkillUpdatePolicy policy) onUpdatePolicyChanged;
  final Future<void> Function() onCopyStorageLocation;

  @override
  State<_SkillDetailsDialog> createState() => _SkillDetailsDialogState();
}

class _SkillDetailsDialogState extends State<_SkillDetailsDialog> {
  late SkillUpdatePolicy _updatePolicy;

  @override
  void initState() {
    super.initState();
    _updatePolicy = widget.content.descriptor.updatePolicy;
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final skill = widget.content.descriptor;
    return ShadDialog(
      title: Text(
        skill.name,
        key: ValueKey<String>('skill-details-title-${skill.id}'),
        style: const TextStyle(fontSize: DesktopThemeTokens.pageTitleFontSize),
      ),
      description: Text(skill.description),
      constraints: const BoxConstraints(maxWidth: 720),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
      child: SizedBox(
        height: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: strings.skillVersion,
                value: skill.version.isEmpty ? '—' : skill.version,
              ),
              _DetailRow(label: strings.skillSource, value: skill.sourceUri),
              _DetailRow(
                label: strings.skillPublisher,
                value:
                    skill.publisherName.isNotEmpty
                        ? skill.publisherName
                        : (skill.publisherId.isEmpty ? '—' : skill.publisherId),
              ),
              _DetailRow(
                label: strings.skillSignature,
                value: _signatureLabel(strings, skill.signatureStatus),
              ),
              if (skill.catalogId.isEmpty)
                _DetailRow(
                  label: strings.skillUpdatePolicy,
                  value: _updatePolicyLabel(strings, _updatePolicy),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          strings.skillUpdatePolicy,
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<SkillUpdatePolicy>(
                          key: const ValueKey<String>('skill-update-policy'),
                          value: _updatePolicy,
                          isExpanded: true,
                          items: [
                            for (final policy in SkillUpdatePolicy.values)
                              DropdownMenuItem(
                                value: policy,
                                child: Text(
                                  _updatePolicyLabel(strings, policy),
                                ),
                              ),
                          ],
                          onChanged: (policy) async {
                            if (policy == null || policy == _updatePolicy) {
                              return;
                            }
                            try {
                              await widget.onUpdatePolicyChanged(policy);
                              if (mounted) {
                                setState(() => _updatePolicy = policy);
                              }
                            } catch (error) {
                              if (mounted) {
                                ShadSonner.of(this.context).show(
                                  ShadToast(
                                    title: Text(
                                      safeFailureMessage(this.context, error),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              _DetailRow(
                label: strings.skillDigest,
                value: skill.contentDigest,
              ),
              _SkillStorageLocationDetail(
                location: skill.rootPath,
                onCopy: widget.onCopyStorageLocation,
              ),
              if (skill.compatibility.isNotEmpty)
                _DetailRow(
                  label: strings.skillCompatibility,
                  value: skill.compatibility,
                ),
              _SkillFilesDetail(files: widget.content.files),
              if (skill.diagnostics.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  strings.skillValidationWarnings,
                  style: ShadTheme.of(context).textTheme.small,
                ),
                const SizedBox(height: 6),
                for (final diagnostic in skill.diagnostics)
                  Text('• ${diagnostic.message}'),
              ],
              const SizedBox(height: 18),
              const ShadSeparator.horizontal(),
              const SizedBox(height: 18),
              SelectableText(
                widget.content.instructions,
                style: ShadTheme.of(context).textTheme.p,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _signatureLabel(S strings, SkillSignatureStatus status) {
    return switch (status) {
      SkillSignatureStatus.unsigned => strings.skillSignatureUnsigned,
      SkillSignatureStatus.verified => strings.skillSignatureVerified,
      SkillSignatureStatus.unknownPublisher =>
        strings.skillSignatureUnknownPublisher,
      SkillSignatureStatus.invalid => strings.skillSignatureInvalid,
    };
  }

  String _updatePolicyLabel(S strings, SkillUpdatePolicy policy) {
    return switch (policy) {
      SkillUpdatePolicy.manual => strings.skillUpdateManual,
      SkillUpdatePolicy.notify => strings.skillUpdateNotify,
      SkillUpdatePolicy.automatic => strings.skillUpdateAutomatic,
      SkillUpdatePolicy.pinned => strings.skillUpdatePinned,
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: ShadTheme.of(context).textTheme.muted),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _SkillStorageLocationDetail extends StatelessWidget {
  const _SkillStorageLocationDetail({
    required this.location,
    required this.onCopy,
  });

  final String location;
  final Future<void> Function() onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey<String>('skill-storage-location'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              S.of(context).skillStorageLocation,
              style: ShadTheme.of(context).textTheme.muted,
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SelectableText(location)),
                const SizedBox(width: 6),
                IconButton(
                  key: const ValueKey<String>('copy-skill-storage-location'),
                  tooltip: S.of(context).copySkillStorageLocation,
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillFilesDetail extends StatelessWidget {
  const _SkillFilesDetail({required this.files});

  final List<String> files;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = ShadTheme.of(context).textTheme.muted;
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      key: const ValueKey<String>('skill-details-files'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(S.of(context).skillFiles, style: mutedStyle),
          ),
          Expanded(
            child:
                files.isEmpty
                    ? const SelectableText('—')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final file in files)
                          Padding(
                            key: ValueKey<String>('skill-file-$file'),
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.insert_drive_file_outlined,
                                    size: 16,
                                    color: iconColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: SelectableText(file)),
                              ],
                            ),
                          ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
