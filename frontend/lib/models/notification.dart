class AppNotification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String? body;
  final String? link;
  final String? readAt;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.link,
    this.readAt,
    required this.createdAt,
  });

  bool get isUnread => readAt == null || readAt!.isEmpty;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String? ?? 'system',
      title: json['title'] as String,
      body: json['body'] as String?,
      link: json['link'] as String?,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at'].toString(),
    );
  }
}