class AuditLog {
  final int id;
  final int? userId;
  final String action;
  final String entityType;
  final int? entityId;
  final String? description;
  final String? ipAddress;
  final String createdAt;
  final String? firstName;
  final String? lastName;
  final String? role;

  AuditLog({
    required this.id,
    this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.description,
    this.ipAddress,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.role,
  });

  String get userName {
    if (firstName == null || lastName == null) return 'System';
    return '$firstName $lastName';
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as int?,
      description: json['description'] as String?,
      ipAddress: json['ip_address'] as String?,
      createdAt: json['created_at'].toString(),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String?,
    );
  }
}