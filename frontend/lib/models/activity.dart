class Activity {
  final int id;
  final String title;
  final String? description;
  final String activityDate;
  final String? activityTime;
  final String? location;
  final String status;
  final String? createdFirstName;
  final String? createdLastName;

  Activity({
    required this.id,
    required this.title,
    this.description,
    required this.activityDate,
    this.activityTime,
    this.location,
    required this.status,
    this.createdFirstName,
    this.createdLastName,
  });

  String? get createdByName =>
      createdFirstName != null && createdLastName != null
          ? '$createdFirstName $createdLastName'
          : null;

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      activityDate: json['activity_date'].toString(),
      activityTime: json['activity_time']?.toString(),
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      createdFirstName: json['created_first_name'] as String?,
      createdLastName: json['created_last_name'] as String?,
    );
  }
}