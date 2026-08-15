import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy model entry point is fully migrated', () {
    expect(File('lib/model/model.dart').existsSync(), isFalse);

    final domainBarrel =
        File('lib/domain/models/models.dart').readAsStringSync();
    expect(domainBarrel, isNot(contains("export '../../model/")));
  });

  test('domain models do not depend on Flutter, data, or UI layers', () {
    final modelFiles = Directory('lib/domain/models')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in modelFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('package:flutter/')),
        reason: '${file.path} imports Flutter',
      );
      expect(
        source,
        isNot(contains('package:stars/data/')),
        reason: '${file.path} imports the data layer',
      );
      expect(
        source,
        isNot(contains('package:stars/ui/')),
        reason: '${file.path} imports the UI layer',
      );
    }
  });

  test('UI depends on data only through the composition root', () {
    final uiFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in uiFiles) {
      if (file.path.endsWith(
        'lib/ui/core/dependency_injection/app_dependencies.dart',
      )) {
        continue;
      }
      expect(
        file.readAsStringSync(),
        isNot(contains('package:stars/data/')),
        reason: '${file.path} bypasses a domain contract',
      );
    }
  });

  test('data and domain layers never depend on UI', () {
    for (final root in const ['lib/data', 'lib/domain']) {
      final files = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in files) {
        expect(
          file.readAsStringSync(),
          isNot(contains('package:stars/ui/')),
          reason: '${file.path} imports the UI layer',
        );
      }
    }
  });

  test('MCP cross-resource mutations stay in domain use cases', () {
    final viewModel =
        File(
          'lib/ui/features/mcp/view_models/mcp_servers_view_model.dart',
        ).readAsStringSync();
    final useCases =
        File(
          'lib/domain/use_cases/mcp_server_mutations.dart',
        ).readAsStringSync();

    expect(
      viewModel,
      contains('package:stars/domain/use_cases/mcp_server_mutations.dart'),
    );
    expect(viewModel, isNot(contains('mcp_credential_store.dart')));
    expect(viewModel, isNot(contains('.saveServer(')));
    expect(viewModel, isNot(contains('.deleteServer(')));
    expect(useCases, contains('final class SaveAndConnectMcpServer'));
    expect(useCases, contains('final class DeleteMcpServer'));
    expect(useCases, contains('enum McpServerMutationOutcome'));
  });

  test('async ChangeNotifiers use disposal guards', () {
    const auditedViewModels = <String>[
      'lib/ui/features/app/view_models/main_shell_view_model.dart',
      'lib/ui/features/app/view_models/startup_view_model.dart',
      'lib/ui/features/bots/view_models/bot_skill_view_model.dart',
      'lib/ui/features/chat/view_models/chat_generation_view_model.dart',
      'lib/ui/features/chat/view_models/chat_skill_view_model.dart',
      'lib/ui/features/chat/view_models/chat_view_model.dart',
      'lib/ui/features/chat/view_models/conversation_memory_view_model.dart',
      'lib/ui/features/chats/view_models/chat_list_view_model.dart',
      'lib/ui/features/feedback/view_models/feedback_view_model.dart',
      'lib/ui/features/mcp/view_models/mcp_servers_view_model.dart',
      'lib/ui/features/profile/view_models/legal_document_view_model.dart',
      'lib/ui/features/profile/view_models/profile_view_model.dart',
    ];

    for (final path in auditedViewModels) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        contains('extends DisposableChangeNotifier'),
        reason: '$path can publish an async completion after disposal',
      );
    }

    final directAsyncNotifiers = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
          final source = file.readAsStringSync();
          return source.contains('extends ChangeNotifier') &&
              source.contains('Future<') &&
              source.contains('notifyListeners');
        });

    for (final file in directAsyncNotifiers) {
      final source = file.readAsStringSync();
      expect(
        RegExp(r'bool _(?:isDisposed|disposed)').hasMatch(source),
        isTrue,
        reason: '${file.path} has no disposal guard',
      );
    }
  });

  test('views do not invoke platform action plugins directly', () {
    const pluginImports = <String>[
      'package:file_picker/',
      'package:gallery_saver_plus/',
      'package:image_picker/',
      'package:share_plus/',
      'package:url_launcher/',
    ];
    final viewFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') && file.path.contains('/views/'),
        );

    for (final file in viewFiles) {
      final source = file.readAsStringSync();
      for (final pluginImport in pluginImports) {
        expect(
          source,
          isNot(contains(pluginImport)),
          reason: '${file.path} invokes a platform plugin directly',
        );
      }
    }
  });

  test('production source files stay below the reviewability limit', () {
    final sourceFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') && !file.path.contains('/generated/'),
        );

    for (final file in sourceFiles) {
      final lineCount = file.readAsLinesSync().length;
      expect(
        lineCount,
        lessThanOrEqualTo(1000),
        reason: '${file.path} has $lineCount lines; split by responsibility',
      );
    }
  });

  test('desktop views use the shared component and semantic token system', () {
    final desktopFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') &&
              (file.path.contains('/desktop_') ||
                  file.path.endsWith('_desktop.dart') ||
                  file.path.endsWith('_desktop_card.dart') ||
                  file.path.endsWith('skill_library_cards.dart') ||
                  file.path.endsWith('skill_library_details.dart')),
        );
    final rawProductColor = RegExp(r'Colors\.(?!transparent\b)');

    for (final file in desktopFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('MenuAnchor(')),
        reason: '${file.path} bypasses StarsDesktopMenu/StarsContextMenu',
      );
      expect(
        source,
        isNot(contains('MenuItemButton(')),
        reason: '${file.path} mixes Material menu items into desktop UI',
      );
      expect(
        RegExp(r'(?<!Lucide)Icons\.').hasMatch(source),
        isFalse,
        reason: '${file.path} mixes Material icons into desktop UI',
      );
      expect(
        source,
        isNot(matches(rawProductColor)),
        reason: '${file.path} defines a product color outside desktop tokens',
      );
      expect(
        source,
        isNot(contains('BorderRadius.circular(')),
        reason: '${file.path} defines a radius outside the desktop spec',
      );
    }
  });

  test('desktop icon actions and notices have one implementation', () {
    const directShadIconButtonAllowlist = <String>{
      'lib/ui/core/widgets/desktop_chat_primitives.dart',
      'lib/ui/features/app/views/desktop_layout_toolbar.dart',
      'lib/ui/features/chat/views/audio_player_widget.dart',
    };
    final uiFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in uiFiles) {
      final source = file.readAsStringSync();
      if (!directShadIconButtonAllowlist.contains(file.path)) {
        expect(
          source,
          isNot(contains('ShadIconButton.')),
          reason: '${file.path} bypasses the 44px StarsDesktopIconAction',
        );
      }
      if (!file.path.endsWith('lib/ui/core/widgets/common.dart')) {
        expect(
          source,
          isNot(anyOf(contains('ShadSonner.'), contains('ScaffoldMessenger.'))),
          reason: '${file.path} bypasses showStarsNotice',
        );
      }
    }
  });

  test('legacy desktop theme and platform aliases stay removed', () {
    final production = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in production) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('DesktopThemeTokens')));
      expect(source, isNot(contains('StarsDesktopTheme.')));
      expect(source, isNot(contains('isDesktopOrTabletPlatform')));
    }
  });

  test('desktop visual and integration regression matrix stays complete', () {
    const appearances = {'light', 'dark', 'high_contrast'};
    const locales = {'zh_CN', 'en'};
    const widths = {1024, 1280, 1600};
    final goldenDirectory = Directory('test/ui/goldens/desktop_visual_matrix');
    final expected = {
      for (final appearance in appearances)
        for (final locale in locales)
          for (final width in widths) '${appearance}_${locale}_$width.png',
    };
    final actual =
        goldenDirectory
            .listSync()
            .whereType<File>()
            .map((file) => file.uri.pathSegments.last)
            .toSet();

    expect(actual, expected);
    expect(
      File('test/ui/desktop_visual_regression_test.dart').existsSync(),
      isTrue,
    );
    expect(
      File('integration_test/desktop_workflow_test.dart').existsSync(),
      isTrue,
    );
    expect(File('test_driver/integration_test.dart').existsSync(), isTrue);
  });
}
