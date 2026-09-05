import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_artifact_preview.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  test('resolves every supported artifact preview type', () {
    expect(
      _previewType(mimeType: 'text/plain', fileName: 'notes.txt'),
      ProjectArtifactPreviewType.text,
    );
    expect(
      _previewType(mimeType: 'application/json', fileName: 'data.json'),
      ProjectArtifactPreviewType.code,
    );
    expect(
      _previewType(mimeType: 'text/plain', fileName: 'README.md'),
      ProjectArtifactPreviewType.markdown,
    );
    expect(
      _previewType(mimeType: 'text/html', fileName: 'index.html'),
      ProjectArtifactPreviewType.html,
    );
    expect(
      _previewType(
        mimeType: 'application/octet-stream',
        fileName: 'diagram.svg',
      ),
      ProjectArtifactPreviewType.image,
    );
    expect(
      _previewType(mimeType: 'application/octet-stream', fileName: 'voice.mp3'),
      ProjectArtifactPreviewType.audio,
    );
    expect(
      _previewType(mimeType: 'application/octet-stream', fileName: 'demo.mp4'),
      ProjectArtifactPreviewType.video,
    );
    expect(
      _previewType(
        mimeType: 'application/pdf',
        fileName: 'document.pdf',
        hasText: false,
      ),
      ProjectArtifactPreviewType.unsupported,
    );
  });

  testWidgets('renders plain text and source code with selectable previews', (
    tester,
  ) async {
    await _pumpPreview(
      tester,
      _read(mimeType: 'text/plain', fileName: 'notes.txt', text: 'plain text'),
    );
    expect(
      find.byKey(const ValueKey<String>('artifact-text-preview')),
      findsOneWidget,
    );
    expect(find.text('plain text'), findsOneWidget);

    await _pumpPreview(
      tester,
      _read(
        mimeType: 'text/x-dart',
        fileName: 'main.dart',
        kind: ProjectArtifactKind.code,
        text: 'void main() {}',
      ),
    );
    expect(
      find.byKey(const ValueKey<String>('artifact-code-preview')),
      findsOneWidget,
    );
    expect(find.text('void main() {}'), findsOneWidget);
  });

  testWidgets('renders Markdown and HTML as formatted documents', (
    tester,
  ) async {
    await _pumpPreview(
      tester,
      _read(
        mimeType: 'text/markdown',
        fileName: 'README.md',
        text: '# Preview',
      ),
    );
    expect(
      find.byKey(const ValueKey<String>('artifact-markdown-preview')),
      findsOneWidget,
    );
    final content = tester.widget<KeyedSubtree>(
      find.byKey(const ValueKey<String>('artifact-preview-content')),
    );
    expect(content.child, isNot(isA<Container>()));

    await _pumpPreview(
      tester,
      _read(
        mimeType: 'text/html',
        fileName: 'index.html',
        kind: ProjectArtifactKind.code,
        text: '<h1>Preview</h1><p>HTML document</p>',
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('artifact-html-preview')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('HTML document'),
      ),
      findsWidgets,
    );
  });

  testWidgets('routes audio and video artifacts to local media players', (
    tester,
  ) async {
    await _pumpPreview(
      tester,
      _read(
        mimeType: 'audio/mpeg',
        fileName: 'voice.mp3',
        kind: ProjectArtifactKind.audio,
      ),
      filePath: '/missing/voice.mp3',
    );
    expect(
      find.byKey(const ValueKey<String>('artifact-audio-preview')),
      findsOneWidget,
    );

    await _pumpPreview(
      tester,
      _read(
        mimeType: 'video/mp4',
        fileName: 'demo.mp4',
        kind: ProjectArtifactKind.video,
      ),
      filePath: '/missing/demo.mp4',
    );
    expect(
      find.byKey(
        const ValueKey<String>('artifact-video-preview-/missing/demo.mp4'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

ProjectArtifactPreviewType _previewType({
  required String mimeType,
  required String fileName,
  ProjectArtifactKind kind = ProjectArtifactKind.other,
  bool hasText = true,
}) => projectArtifactPreviewType(
  mimeType: mimeType,
  fileName: fileName,
  kind: kind,
  hasText: hasText,
);

Future<void> _pumpPreview(
  WidgetTester tester,
  ProjectArtifactReadResult read, {
  String? filePath,
}) async {
  await tester.pumpWidget(
    shadHarness(
      brightness: Brightness.light,
      homeBuilder:
          (_) => Scaffold(
            body: Center(
              child: SizedBox(
                width: 700,
                height: 500,
                child: ProjectArtifactPreview(read: read, filePath: filePath),
              ),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

ProjectArtifactReadResult _read({
  required String mimeType,
  required String fileName,
  String? text,
  ProjectArtifactKind kind = ProjectArtifactKind.document,
}) {
  final now = DateTime(2026, 9, 5);
  final bytes = Uint8List.fromList(utf8.encode(text ?? ''));
  final artifact = ProjectArtifact(
    id: 'artifact-preview',
    projectId: 'project-preview',
    name: fileName,
    relativePath: fileName,
    kind: kind,
    mimeType: mimeType,
    currentVersionId: 'version-preview',
    searchStatus: ProjectArtifactSearchStatus.indexed,
    createdByType: ProjectArtifactActorType.agent,
    createdById: 'agent-preview',
    sourceRunId: 'run-preview',
    createdAt: now,
    updatedAt: now,
  );
  final version = ProjectArtifactVersion(
    id: 'version-preview',
    artifactId: artifact.id,
    versionNumber: 1,
    relativeBlobPath: 'artifacts/blobs/preview/content',
    contentDigest:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    byteLength: bytes.length,
    mimeType: mimeType,
    createdByType: ProjectArtifactActorType.agent,
    createdById: 'agent-preview',
    sourceRunId: 'run-preview',
    createdAt: now,
  );
  return ProjectArtifactReadResult(
    artifact: artifact,
    version: version,
    bytes: bytes,
    offset: 0,
    nextOffset: bytes.length,
    endOfFile: true,
    text: text,
  );
}
