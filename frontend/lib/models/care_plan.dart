// Care plan model.
class CarePlan {
  final int id;
  final int residentId;
  final String title;
  final String? careNeed;
  final String? goal;
  final String? careActions;
  final String? frequency;
  final int? assignedStaffId;
  final String? startDate;
  final String? reviewDate;
  final String status;
  final String? notes;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;
  final String? staffFirstName;
  final String? staffLastName;

  CarePlan({
    required this.id,
    required this.residentId,
    required this.title,
    this.careNeed,
    this.goal,
    this.careActions,
    this.frequency,
    this.assignedStaffId,
    this.startDate,
    this.reviewDate,
    required this.status,
    this.notes,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
    this.staffFirstName,
    this.staffLastName,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  String? get staffName =>
      staffFirstName != null && staffLastName != null
          ? '$staffFirstName $staffLastName'
          : null;

  factory CarePlan.fromJson(Map<String, dynamic> json) {
    return CarePlan(
      id: json['id'] as int,
      residentId: json['resident_id'] as int,
      title: json['title'] as String,
      careNeed: json['care_need'] as String?,
      goal: json['goal'] as String?,
      careActions: json['care_actions'] as String?,
      frequency: json['frequency'] as String?,
      assignedStaffId: json['assigned_staff_id'] as int?,
      startDate: json['start_date']?.toString(),
      reviewDate: json['review_date']?.toString(),
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
      staffFirstName: json['staff_first_name'] as String?,
      staffLastName: json['staff_last_name'] as String?,
    );
  }
}