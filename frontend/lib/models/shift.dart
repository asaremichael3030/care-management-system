class Shift {
  final int id;
  final int staffId;
  final String shiftDate;
  final String startTime;
  final String endTime;
  final String shiftType;
  final String status;
  final String? notes;
  final String? staffFirstName;
  final String? staffLastName;
  final String? staffRole;
  final String? staffDepartment;

  Shift({
    required this.id,
    required this.staffId,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
    required this.shiftType,
    required this.status,
    this.notes,
    this.staffFirstName,
    this.staffLastName,
    this.staffRole,
    this.staffDepartment,
  });

  String? get staffName =>
      staffFirstName != null && staffLastName != null
          ? '$staffFirstName $staffLastName'
          : null;

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      staffId: json['staff_id'] as int,
      shiftDate: json['shift_date'].toString(),
      startTime: json['start_time'].toString(),
      endTime: json['end_time'].toString(),
      shiftType: json['shift_type'] as String? ?? 'Morning',
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
      staffFirstName: json['staff_first_name'] as String?,
      staffLastName: json['staff_last_name'] as String?,
      staffRole: json['staff_role'] as String?,
      staffDepartment: json['staff_department'] as String?,
    );
  }
}