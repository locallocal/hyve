final class AgentMemorySafety {
  const AgentMemorySafety();

  bool isSecretLike(String content) {
    final value = content.trim();
    if (value.isEmpty) return false;
    return _patterns.any((pattern) => pattern.hasMatch(value));
  }

  String redact(String content) {
    var result = content;
    for (final pattern in _patterns) {
      result = result.replaceAll(pattern, '[redacted secret-like content]');
    }
    return result;
  }
}

final List<RegExp> _patterns = <RegExp>[
  RegExp(
    r'''(?:api[_-]?key|access[_-]?token|refresh[_-]?token|password|passwd|client[_-]?secret)\s*[:=]\s*["']?[^\s,"']{8,}''',
    caseSensitive: false,
  ),
  RegExp(r'\bsk-[A-Za-z0-9_-]{16,}\b'),
  RegExp(r'\bgh[pousr]_[A-Za-z0-9]{20,}\b'),
  RegExp(r'\bAKIA[0-9A-Z]{16}\b'),
  RegExp(
    r'-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----',
  ),
  RegExp(r'\b(?:eyJ[A-Za-z0-9_-]+\.){2}[A-Za-z0-9_-]+\b'),
];
