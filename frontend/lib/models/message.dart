class Message {
  final int id;
  final int senderId;
  final int recipientId;
  final String? subject;
  final String body;
  final String? readAt;
  final String createdAt;

  final String? senderFirstName;
  final String? senderLastName;
  final String? senderRole;
  final String? recipientFirstName;
  final String? recipientLastName;
  final String? recipientRole;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    this.subject,
    required this.body,
    this.readAt,
    required this.createdAt,
    this.senderFirstName,
    this.senderLastName,
    this.senderRole,
    this.recipientFirstName,
    this.recipientLastName,
    this.recipientRole,
  });

  bool get isUnread => readAt == null || readAt!.isEmpty;

  String get senderName =>
      '${senderFirstName ?? ''} ${senderLastName ?? ''}'.trim();

  String get recipientName =>
      '${recipientFirstName ?? ''} ${recipientLastName ?? ''}'.trim();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      recipientId: json['recipient_id'] as int,
      subject: json['subject'] as String?,
      body: json['body'] as String,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at'].toString(),
      senderFirstName: json['sender_first_name'] as String?,
      senderLastName: json['sender_last_name'] as String?,
      senderRole: json['sender_role'] as String?,
      recipientFirstName: json['recipient_first_name'] as String?,
      recipientLastName: json['recipient_last_name'] as String?,
      recipientRole: json['recipient_role'] as String?,
    );
  }
}

class Contact {
  final int id;
  final String firstName;
  final String lastName;
  final String role;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  String get fullName => '$firstName $lastName';

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
    );
  }
}