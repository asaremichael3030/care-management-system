// Summary report returned by /api/reports/summary.
class ReportSummary {
  final int residentsTotal;
  final List<CountItem> residentsByStatus;

  final int medicationsTotal;
  final int medicationsActive;
  final int medicationRecordsThisMonth;

  final int incidentsTotal;
  final int incidentsThisMonth;
  final List<CountItem> incidentsByStatus;
  final List<CountItem> incidentsByType;

  final int careTasksTotal;
  final int careTasksCompleted;
  final List<CountItem> careTasksByStatus;

  final int staffTotal;
  final List<CountItem> staffByRole;
  final List<CountItem> staffByStatus;

  final int shiftsThisWeek;

  final int carePlansTotal;
  final int carePlansDueForReview;
  final int carePlansOverdue;
  final List<CountItem> carePlansByStatus;

  final int familiesLinked;
  final int messagesTotal;
  final int messagesThisWeek;

  ReportSummary({
    required this.residentsTotal,
    required this.residentsByStatus,
    required this.medicationsTotal,
    required this.medicationsActive,
    required this.medicationRecordsThisMonth,
    required this.incidentsTotal,
    required this.incidentsThisMonth,
    required this.incidentsByStatus,
    required this.incidentsByType,
    required this.careTasksTotal,
    required this.careTasksCompleted,
    required this.careTasksByStatus,
    required this.staffTotal,
    required this.staffByRole,
    required this.staffByStatus,
    required this.shiftsThisWeek,
    required this.carePlansTotal,
    required this.carePlansDueForReview,
    required this.carePlansOverdue,
    required this.carePlansByStatus,
    required this.familiesLinked,
    required this.messagesTotal,
    required this.messagesThisWeek,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    List<CountItem> parseCounts(dynamic list) {
      if (list is! List) return [];
      return list
          .map((e) => CountItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final residents = json['residents'] as Map<String, dynamic>;
    final medications = json['medications'] as Map<String, dynamic>;
    final incidents = json['incidents'] as Map<String, dynamic>;
    final careTasks = json['careTasks'] as Map<String, dynamic>;
    final staff = json['staff'] as Map<String, dynamic>;
    final shifts = json['shifts'] as Map<String, dynamic>;
    final carePlans = json['carePlans'] as Map<String, dynamic>;
    final family = json['family'] as Map<String, dynamic>;
    final messages = json['messages'] as Map<String, dynamic>;

    return ReportSummary(
      residentsTotal: residents['total'] as int,
      residentsByStatus: parseCounts(residents['byStatus']),
      medicationsTotal: medications['total'] as int,
      medicationsActive: medications['active'] as int,
      medicationRecordsThisMonth:
          medications['recordsThisMonth'] as int,
      incidentsTotal: incidents['total'] as int,
      incidentsThisMonth: incidents['thisMonth'] as int,
      incidentsByStatus: parseCounts(incidents['byStatus']),
      incidentsByType: parseCounts(incidents['byType']),
      careTasksTotal: careTasks['total'] as int,
      careTasksCompleted: careTasks['completed'] as int,
      careTasksByStatus: parseCounts(careTasks['byStatus']),
      staffTotal: staff['total'] as int,
      staffByRole: parseCounts(staff['byRole']),
      staffByStatus: parseCounts(staff['byStatus']),
      shiftsThisWeek: shifts['thisWeek'] as int,
      carePlansTotal: carePlans['total'] as int,
      carePlansDueForReview: carePlans['dueForReview'] as int,
      carePlansOverdue: carePlans['overdue'] as int,
      carePlansByStatus: parseCounts(carePlans['byStatus']),
      familiesLinked: family['linked'] as int,
      messagesTotal: messages['total'] as int,
      messagesThisWeek: messages['thisWeek'] as int,
    );
  }
}

// A label + count pair used inside the report.
class CountItem {
  final String label;
  final int count;

  CountItem({required this.label, required this.count});

  factory CountItem.fromJson(Map<String, dynamic> json) {
    final label = (json['status'] ?? json['role'] ?? json['type'] ?? '-')
        .toString();
    return CountItem(label: label, count: json['count'] as int);
  }
}