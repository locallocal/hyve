class Chat {
  Chat({
    required this.id,
    required Iterable<String> botIds,
    this.name = '',
    this.lastMessage = '',
    required this.lastMessageTimestamp,
    required this.createTimestamp,
    required this.modifyTimestamp,
  }) : botIds = List<String>.unmodifiable(
         <String>{...botIds.map((id) => id.trim())}..remove(''),
       );

  final String id;
  final String name;
  final List<String> botIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final DateTime createTimestamp;
  final DateTime modifyTimestamp;

  List<String> get projectBotIds => botIds;

  Chat copyWith({
    String? name,
    List<String>? botIds,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    DateTime? modifyTimestamp,
  }) => Chat(
    id: id,
    name: name ?? this.name,
    botIds: botIds ?? this.botIds,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
    createTimestamp: createTimestamp,
    modifyTimestamp: modifyTimestamp ?? this.modifyTimestamp,
  );
}
