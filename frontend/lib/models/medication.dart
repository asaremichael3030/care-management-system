class Medication {
  final int id;
  final int residentId;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? route;
  final String? startDate;
  final String? endDate;
  final String? instructions;
  final String? prescriber;
  final bool isActive;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;

  Medication({
    required this.id,
    required this.residentId,
    required this.name,
    this.dosage,
    this.frequency,
    this.route,
    this.startDate,
    this.endDate,
    this.instructions,
    this.prescriber,
    required this.isActive,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as int,
      residentId: json['resident_id'] as int,
      name: json['name'] as String,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      route: json['route'] as String?,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      instructions: json['instructions'] as String?,
      prescriber: json['prescriber'] as String?,
      isActive: json['is_active'] == true,
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
    );
  }
}

class MedicationRecord {
  final int id;
  final int medicationId;
  final int residentId;
  final int? administeredBy;
  final String? administeredAt;
  final String status;
  final String? notes;
  final String? administeredFirstName;
  final String? administeredLastName;

  MedicationRecord({
    required this.id,
    required this.medicationId,
    required this.residentId,
    this.administeredBy,
    this.administeredAt,
    required this.status,
    this.notes,
    this.administeredFirstName,
    this.administeredLastName,
  });

  String? get administeredByName =>
      administeredFirstName != null && administeredLastName != null
          ? '$administeredFirstName $administeredLastName'
          : null;

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id'] as int,
      medicationId: json['medication_id'] as int,
      residentId: json['resident_id'] as int,
      administeredBy: json['administered_by'] as int?,
      administeredAt: json['administered_at']?.toString(),
      status: json['status'] as String? ?? 'given',
      notes: json['notes'] as String?,
      administeredFirstName: json['administered_first_name'] as String?,
      administeredLastName: json['administered_last_name'] as String?,
    );
  }
}