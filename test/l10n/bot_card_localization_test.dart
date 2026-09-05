import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/generated/l10n.dart';

void main() {
  final expected = <Locale, ({String details, String edit, String delete})>{
    Locale('en', 'US'): (details: 'Details', edit: 'Edit', delete: 'Delete'),
    Locale('zh', 'CN'): (details: '详情', edit: '编辑', delete: '删除'),
    Locale('zh', 'TW'): (details: '詳情', edit: '編輯', delete: '刪除'),
    Locale('ja', 'JP'): (details: '詳細', edit: '編集', delete: '削除'),
    Locale('fr', 'FR'): (
      details: 'Détails',
      edit: 'Modifier',
      delete: 'Supprimer',
    ),
    Locale('de', 'DE'): (
      details: 'Einzelheiten',
      edit: 'Bearbeiten',
      delete: 'Löschen',
    ),
    Locale('ko', 'KR'): (details: '세부 정보', edit: '편집', delete: '삭제'),
    Locale('ru', 'RU'): (
      details: 'Сведения',
      edit: 'Редактировать',
      delete: 'Удалить',
    ),
    Locale('es', 'ES'): (
      details: 'Detalles',
      edit: 'Editar',
      delete: 'Eliminar',
    ),
    Locale('hi', 'IN'): (
      details: 'विवरण',
      edit: 'संपादित करें',
      delete: 'हटाएं',
    ),
    Locale('pt', 'BR'): (
      details: 'Detalhes',
      edit: 'Editar',
      delete: 'Excluir',
    ),
    Locale('it', 'IT'): (
      details: 'Dettagli',
      edit: 'Modifica',
      delete: 'Elimina',
    ),
  };

  test('every locale defines the desktop Bot card actions', () {
    for (final locale in expected.keys) {
      final fileName =
          locale.languageCode == 'en'
              ? 'intl_en.arb'
              : locale.languageCode == 'it'
              ? 'intl_it_IT.arb'
              : 'intl_${locale.languageCode}_${locale.countryCode}.arb';
      final messages =
          jsonDecode(File('lib/l10n/$fileName').readAsStringSync())
              as Map<String, dynamic>;

      for (final key in ['details', 'startChatting', 'edit', 'delete']) {
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
      expect(
        S.current.details,
        entry.value.details,
        reason: entry.key.toString(),
      );
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
