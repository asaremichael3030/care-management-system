// Resident model. Residents are not users and cannot log in.
class Resident {
  final int id;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? room;
  final String? admissionDate;
  final String status;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? careNeeds;
  final String? allergies;
  final String? importantNotes;

  Resident({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.room,
    this.admissionDate,
    required this.status,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.careNeeds,
    this.allergies,
    this.importantNotes,
  });

  String get fullName => '$firstName $lastName';

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender'] as String?,
      room: json['room'] as String?,
      admissionDate: json['admission_date']?.toString(),
      status: json['status'] as String? ?? 'active',
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      careNeeds: json['care_needs'] as String?,
      allergies: json['allergies'] as String?,
      importantNotes: json['important_notes'] as String?,
    );
  }
}