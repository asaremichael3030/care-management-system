// Care note model.
class CareNote {
  final int id;
  final int residentId;
  final String noteType;
  final String content;
  final int? recordedBy;
  final String? recordedAt;
  final bool visibleToFamily;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;
  final String? recordedFirstName;
  final String? recordedLastName;

  CareNote({
    required this.id,
    required this.residentId,
    required this.noteType,
    required this.content,
    this.recordedBy,
    this.recordedAt,
    required this.visibleToFamily,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
    this.recordedFirstName,
    this.recordedLastName,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  String? get recordedByName =>
      recordedFirstName != null && recordedLastName != null
          ? '$recordedFirstName $recordedLastName'
          : null;

  factory CareNote.fromJson(Map<String, dynamic> json) {
    return CareNote(
      id: json['id'] as int,
      residentId: json['resident_id'] as int,
      noteType: json['note_type'] as String,
      content: json['content'] as String,
      recordedBy: json['recorded_by'] as int?,
      recordedAt: json['recorded_at']?.toString(),
      visibleToFamily: json['visible_to_family'] == true,
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
      recordedFirstName: json['recorded_first_name'] as String?,
      recordedLastName: json['recorded_last_name'] as String?,
    );
  }
}