class Chat {
  const Chat({
    required this.id,
    required this.botId,
    this.name = '',
    this.botIds = const <String>[],
    this.lastMessage = '',
    required this.lastMessageTimestamp,
    required this.createTimestamp,
    required this.modifyTimestamp,
  });

  final String id;
  final String botId;
  final String name;
  final List<String> botIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final DateTime createTimestamp;
  final DateTime modifyTimestamp;

  List<String> get projectBotIds {
    final ids = <String>{botId, ...botIds}..remove('');
    return List<String>.unmodifiable(ids);
  }
}
