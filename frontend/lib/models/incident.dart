class Incident {
  final int id;
  final int? residentId;
  final String incidentType;
  final String occurredDate;
  final String? occurredTime;
  final String? location;
  final String description;
  final String? peopleInvolved;
  final String? actionTaken;
  final int? reportedBy;
  final String status;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;
  final String? reporterFirstName;
  final String? reporterLastName;

  Incident({
    required this.id,
    this.residentId,
    required this.incidentType,
    required this.occurredDate,
    this.occurredTime,
    this.location,
    required this.description,
    this.peopleInvolved,
    this.actionTaken,
    this.reportedBy,
    required this.status,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
    this.reporterFirstName,
    this.reporterLastName,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  String? get reporterName =>
      reporterFirstName != null && reporterLastName != null
          ? '$reporterFirstName $reporterLastName'
          : null;

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as int,
      residentId: json['resident_id'] as int?,
      incidentType: json['incident_type'] as String,
      occurredDate: json['occurred_date'].toString(),
      occurredTime: json['occurred_time']?.toString(),
      location: json['location'] as String?,
      description: json['description'] as String,
      peopleInvolved: json['people_involved'] as String?,
      actionTaken: json['action_taken'] as String?,
      reportedBy: json['reported_by'] as int?,
      status: json['status'] as String? ?? 'open',
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
      reporterFirstName: json['reporter_first_name'] as String?,
      reporterLastName: json['reporter_last_name'] as String?,
    );
  }
}