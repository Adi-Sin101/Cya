/// A neutral memory has history, not task completion or a scheduled reminder.
class Memory {
  const Memory({
    required this.id,
    required this.text,
    required this.revisionId,
    required this.revision,
    required this.capturedAt,
    required this.archived,
    this.kind = 'text',
    this.matchingSegment,
    this.connectionKind,
    this.connectionOrigin,
  });
  final String id;
  final String text;
  final String revisionId;
  final int revision;
  final DateTime capturedAt;
  final bool archived;
  final String kind;
  final int? matchingSegment;
  final String? connectionKind;
  final String? connectionOrigin;
  bool get isAudio => kind == 'audio';
  String get displayText => text.isEmpty && isAudio ? 'Voice thought' : text;
}
