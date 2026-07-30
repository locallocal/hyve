import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/generated/l10n.dart';

void main() {
  final expected = <Locale, ({String edit, String delete})>{
    Locale('en', 'US'): (edit: 'Edit', delete: 'Delete'),
    Locale('zh', 'CN'): (edit: '编辑', delete: '删除'),
    Locale('zh', 'TW'): (edit: '編輯', delete: '刪除'),
    Locale('ja', 'JP'): (edit: '編集', delete: '削除'),
    Locale('fr', 'FR'): (edit: 'Modifier', delete: 'Supprimer'),
    Locale('de', 'DE'): (edit: 'Bearbeiten', delete: 'Löschen'),
    Locale('ko', 'KR'): (edit: '편집', delete: '삭제'),
    Locale('ru', 'RU'): (edit: 'Редактировать', delete: 'Удалить'),
    Locale('es', 'ES'): (edit: 'Editar', delete: 'Eliminar'),
    Locale('hi', 'IN'): (edit: 'संपादित करें', delete: 'हटाएं'),
    Locale('pt', 'BR'): (edit: 'Editar', delete: 'Excluir'),
    Locale('it', 'IT'): (edit: 'Modifica', delete: 'Elimina'),
  };

  test('every locale defines the desktop Bot card actions', () {
    for (final locale in expected.keys) {
      final fileName =
          locale.languageCode == 'en'
              ? 'intl_en.arb'
              : locale.languageCode == 'it'
              ? 'intl_it_it.arb'
              : 'intl_${locale.languageCode}_${locale.countryCode}.arb';
      final messages =
          jsonDecode(File('lib/l10n/$fileName').readAsStringSync())
              as Map<String, dynamic>;

      for (final key in ['startChatting', 'edit', 'delete']) {
        expect(
          messages[key],
          isA<String>().having(
            (value) => value.trim(),
            'trimmed value',
            isNotEmpty,
          ),
          reason: '$fileName is missing $key',
        );
      }
    }
  });

  test('generated desktop Bot card actions load for every locale', () async {
    for (final entry in expected.entries) {
      await S.load(entry.key);
      expect(S.current.edit, entry.value.edit, reason: entry.key.toString());
      expect(
        S.current.delete,
        entry.value.delete,
        reason: entry.key.toString(),
      );
      expect(S.current.startChatting.trim(), isNotEmpty);
    }
  });
}
