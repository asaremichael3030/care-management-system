class Staff {
  final int id;
  final int userId;
  final String? jobTitle;
  final String? department;
  final String employmentStatus;
  final String? hireDate;
  final String? notes;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final String userStatus;

  Staff({
    required this.id,
    required this.userId,
    this.jobTitle,
    this.department,
    required this.employmentStatus,
    this.hireDate,
    this.notes,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    required this.userStatus,
  });

  String get fullName => '$firstName $lastName';

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      jobTitle: json['job_title'] as String?,
      department: json['department'] as String?,
      employmentStatus: json['employment_status'] as String? ?? 'active',
      hireDate: json['hire_date']?.toString(),
      notes: json['notes'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      userStatus: json['user_status'] as String? ?? 'active',
    );
  }
}