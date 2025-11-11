class FeedingRecord {
  final String id;
  final DateTime time;
  final int amount; // ml
  final String type; // 'breast', 'bottle', 'solid'

  FeedingRecord({
    required this.id,
    required this.time,
    required this.amount,
    this.type = 'bottle',
  });

  String get timeString {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
