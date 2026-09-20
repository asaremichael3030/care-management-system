// A link between a family user and a resident.
class FamilyLink {
  final int id;
  final int userId;
  final int residentId;
  final String? relationship;
  final bool isPrimary;
  final String userFirstName;
  final String userLastName;
  final String userEmail;
  final String residentFirstName;
  final String residentLastName;
  final String? residentRoom;

  FamilyLink({
    required this.id,
    required this.userId,
    required this.residentId,
    this.relationship,
    required this.isPrimary,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    required this.residentFirstName,
    required this.residentLastName,
    this.residentRoom,
  });

  String get userName => '$userFirstName $userLastName';
  String get residentName => '$residentFirstName $residentLastName';

  factory FamilyLink.fromJson(Map<String, dynamic> json) {
    return FamilyLink(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      residentId: json['resident_id'] as int,
      relationship: json['relationship'] as String?,
      isPrimary: json['is_primary'] == true,
      userFirstName: json['user_first_name'] as String,
      userLastName: json['user_last_name'] as String,
      userEmail: json['user_email'] as String,
      residentFirstName: json['resident_first_name'] as String,
      residentLastName: json['resident_last_name'] as String,
      residentRoom: json['resident_room'] as String?,
    );
  }
}