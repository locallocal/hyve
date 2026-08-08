import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:stars/domain/models/conversation_history.dart';

final class SystemConversationHistorySkill {
  static const assetPath = 'assets/skills/system/conversation-history/SKILL.md';

  bool _isValid = false;

  bool get isValid => _isValid;
  String get contentDigest => conversationHistorySkillContentDigest;
  int get promptVersion => conversationHistorySkillPromptVersion;

  Future<void> validate({AssetBundle? bundle}) async {
    _isValid = false;
    final content = await (bundle ?? rootBundle).loadString(
      assetPath,
      cache: false,
    );
    final digest = sha256.convert(utf8.encode(content)).toString();
    if (digest != conversationHistorySkillContentDigest) {
      throw const FormatException(
        'Built-in conversation history Skill failed integrity validation.',
      );
    }
    _isValid = true;
  }
}
