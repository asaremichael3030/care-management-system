class ResidentDocument {
  final int id;
  final int residentId;
  final String title;
  final String documentType;
  final String? description;
  final String fileUrl;
  final bool visibleToFamily;
  final int? uploadedBy;
  final String createdAt;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;
  final String? uploadedFirstName;
  final String? uploadedLastName;

  ResidentDocument({
    required this.id,
    required this.residentId,
    required this.title,
    required this.documentType,
    this.description,
    required this.fileUrl,
    required this.visibleToFamily,
    this.uploadedBy,
    required this.createdAt,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
    this.uploadedFirstName,
    this.uploadedLastName,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  String? get uploadedByName =>
      uploadedFirstName != null && uploadedLastName != null
          ? '$uploadedFirstName $uploadedLastName'
          : null;

  factory ResidentDocument.fromJson(Map<String, dynamic> json) {
    return ResidentDocument(
      id: json['id'] as int,
      residentId: json['resident_id'] as int,
      title: json['title'] as String,
      documentType: json['document_type'] as String? ?? 'Other',
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      visibleToFamily: json['visible_to_family'] == true,
      uploadedBy: json['uploaded_by'] as int?,
      createdAt: json['created_at'].toString(),
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
      uploadedFirstName: json['uploaded_first_name'] as String?,
      uploadedLastName: json['uploaded_last_name'] as String?,
    );
  }
}