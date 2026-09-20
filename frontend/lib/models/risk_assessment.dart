class RiskAssessment {
  final int id;
  final int residentId;
  final String riskType;
  final String riskLevel;
  final String? description;
  final String? mitigation;
  final String? reviewDate;
  final String status;
  final int? assessedBy;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;
  final String? assessedFirstName;
  final String? assessedLastName;

  RiskAssessment({
    required this.id,
    required this.residentId,
    required this.riskType,
    required this.riskLevel,
    this.description,
    this.mitigation,
    this.reviewDate,
    required this.status,
    this.assessedBy,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
    this.assessedFirstName,
    this.assessedLastName,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  String? get assessedByName =>
      assessedFirstName != null && assessedLastName != null
          ? '$assessedFirstName $assessedLastName'
          : null;

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      id: json['id'] as int,
      residentId: json['resident_id'] as int,
      riskType: json['risk_type'] as String,
      riskLevel: json['risk_level'] as String? ?? 'low',
      description: json['description'] as String?,
      mitigation: json['mitigation'] as String?,
      reviewDate: json['review_date']?.toString(),
      status: json['status'] as String? ?? 'active',
      assessedBy: json['assessed_by'] as int?,
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
      assessedFirstName: json['assessed_first_name'] as String?,
      assessedLastName: json['assessed_last_name'] as String?,
    );
  }
}