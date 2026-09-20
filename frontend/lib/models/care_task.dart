// Care task model.
class CareTask {
  final int id;
  final int residentId;
  final int? assignedTo;
  final String taskType;
  final String title;
  final String? description;
  final String? dueDate;
  final String? dueTime;
  final String status;
  final String? completedAt;
  final int? completedBy;
  final String? notes;
  final String? residentFirstName;
  final String? residentLastName;
  final String? residentRoom;
  final String? assignedFirstName;
  final String? assignedLastName;

  CareTask({
    required this.id,
    required this.residentId,
    this.assignedTo,
    required this.taskType,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    required this.status,
    this.completedAt,
    this.completedBy,
    this.notes,
    this.residentFirstName,
    this.residentLastName,
    this.residentRoom,
    this.assignedFirstName,
    this.assignedLastName,
  });

  String? get residentName =>
      residentFirstName != null && residentLastName != null
          ? '$residentFirstName $residentLastName'
          : null;

  String? get assignedName =>
      assignedFirstName != null && assignedLastName != null
          ? '$assignedFirstName $assignedLastName'
          : null;

  factory CareTask.fromJson(Map<String, dynamic> json) {
    return CareTask(
      id: json['id'] as int,
      residentId: json['resident_id'] as int,
      assignedTo: json['assigned_to'] as int?,
      taskType: json['task_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date']?.toString(),
      dueTime: json['due_time']?.toString(),
      status: json['status'] as String? ?? 'pending',
      completedAt: json['completed_at']?.toString(),
      completedBy: json['completed_by'] as int?,
      notes: json['notes'] as String?,
      residentFirstName: json['resident_first_name'] as String?,
      residentLastName: json['resident_last_name'] as String?,
      residentRoom: json['resident_room'] as String?,
      assignedFirstName: json['assigned_first_name'] as String?,
      assignedLastName: json['assigned_last_name'] as String?,
    );
  }
}