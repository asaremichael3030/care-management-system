import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../theme.dart';
import '../care_notes/care_notes_screen.dart';
import '../care_plans/care_plans_screen.dart';
import '../care_tasks/care_tasks_screen.dart';
import '../medications/medications_screen.dart';
import '../residents/residents_screen.dart';
import 'dashboard_layout.dart';
import '../incidents/incidents_screen.dart';
import '../shifts/shifts_screen.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';

class CareWorkerDashboard extends StatefulWidget {
  const CareWorkerDashboard({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  State<CareWorkerDashboard> createState() => _CareWorkerDashboardState();
}

class _CareWorkerDashboardState extends State<CareWorkerDashboard> {
  static const List<DashboardNavItem> _navItems = [
    DashboardNavItem('Dashboard', Icons.dashboard_outlined),
    DashboardNavItem('My Residents', Icons.elderly_outlined),
    DashboardNavItem('Today\'s Tasks', Icons.checklist_outlined),
    DashboardNavItem('Care Plans', Icons.assignment_outlined),
    DashboardNavItem('Medication', Icons.medication_outlined),
    DashboardNavItem('Care Notes', Icons.note_alt_outlined),
    DashboardNavItem('Incidents', Icons.warning_amber_outlined),
    DashboardNavItem('My Shifts', Icons.calendar_today_outlined),
    DashboardNavItem('Messages', Icons.chat_bubble_outline),
    DashboardNavItem('Notifications', Icons.notifications_none),
    DashboardNavItem('Settings', Icons.settings_outlined),
  ];

  String _active = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      user: widget.user,
      navItems: _navItems,
      activeItem: _active,
      onSelect: (item) => setState(() => _active = item),
      onLogout: widget.onLogout,
      child: _buildActivePage(),
    );
  }

  Widget _buildActivePage() {
    switch (_active) {
      case 'Dashboard':
        return _buildDashboardContent();
      case 'My Residents':
        return ResidentsScreen(currentUser: widget.user);
      case "Today's Tasks":
        return CareTasksScreen(currentUser: widget.user, mode: 'mine');
      case 'Care Plans':
        return CarePlansScreen(currentUser: widget.user);
      case 'Medication':
        return MedicationsScreen(currentUser: widget.user);
      case 'Care Notes':
        return CareNotesScreen(currentUser: widget.user);
      case 'Incidents':
        return IncidentsScreen(currentUser: widget.user);
      case 'My Shifts':
        return ShiftsScreen(currentUser: widget.user, mode: 'mine');
      case 'Messages':
        return MessagesScreen(currentUser: widget.user);
      case 'Notifications':
        return NotificationsScreen(currentUser: widget.user);
        case 'Settings':
  return SettingsScreen(currentUser: widget.user);
      default:
        return DashboardPlaceholder(title: _active);
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and shift row.
          LayoutBuilder(
            builder: (context, constraints) {
              final greeting = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, ${widget.user.firstName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Here is your care schedule for today.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              );

              const shiftCard = _ShiftTodayCard();

              if (constraints.maxWidth >= 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: greeting),
                    const SizedBox(width: 16),
                    shiftCard,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  greeting,
                  const SizedBox(height: 16),
                  shiftCard,
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Stat cards row.
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 900 ? 4 : 2;
              final double spacing = 12;
              final double cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.check_circle_outline,
                    value: '6',
                    label: "Today's Tasks",
                    subLabel: '4 of 6 completed',
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.medication_outlined,
                    value: '5',
                    label: 'Medication Due',
                    subLabel: 'Residents',
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.note_alt_outlined,
                    value: '3',
                    label: 'Care Notes',
                    subLabel: 'New notes',
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    width: cardWidth,
                    icon: Icons.warning_amber_outlined,
                    value: '0',
                    label: 'Incidents',
                    subLabel: 'Reported',
                    color: AppColors.danger,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Today's tasks and weekly chart.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTodayTasks()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildWeeklyChart()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildTodayTasks(),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Residents and quick links.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildMyResidents()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildQuickLinks()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildMyResidents(),
                  const SizedBox(height: 16),
                  _buildQuickLinks(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasks() {
    // Temporary mock data until Daily Care module is built.
    const tasks = [
      ('Personal care - Mrs. Smith', '08:00 AM', 'Completed', AppColors.success),
      ('Medication - Mr. Brown', '09:30 AM', 'Due', AppColors.warning),
      ('Meal support - Mrs. Evans', '12:00 PM', 'Pending', AppColors.textMuted),
      ('Mobility support - Mr. Wilson', '02:00 PM', 'Pending', AppColors.textMuted),
      ('Care note - Mrs. Taylor', '03:00 PM', 'Pending', AppColors.textMuted),
    ];

    return _SectionCard(
      title: "Today's Care Tasks",
      trailing: TextButton(
        onPressed: () => setState(() => _active = "Today's Tasks"),
        child: const Text(
          'View All',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: tasks.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: t.$4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.$2,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: t.$4.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.$3,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: t.$4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Temporary mock data for the weekly task counts.
    const values = [8, 12, 10, 14, 11, 6, 4];
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _SectionCard(
      title: 'Care Tasks This Week',
      child: SizedBox(
        height: 160,
        child: CustomPaint(
          painter: _BarChartPainter(
            values: values,
            labels: labels,
            barColor: AppColors.primary,
            labelColor: AppColors.textMuted,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _buildMyResidents() {
    // Temporary mock data until Residents module is built.
    const residents = [
      ('Mrs. Mary Smith', 'Room 12', 'Personal Care', 'Completed', AppColors.success),
      ('Mr. John Brown', 'Room 15', 'Medication', 'Due', AppColors.warning),
      ('Mrs. Alice Taylor', 'Room 08', 'Mobility Support', 'Pending', AppColors.textMuted),
    ];

    return _SectionCard(
      title: 'My Residents',
      trailing: TextButton(
        onPressed: () => setState(() => _active = 'My Residents'),
        child: const Text(
          'View All',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: residents.map((r) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    r.$1.split(' ').last.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.$2,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    r.$3,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: r.$5.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.$4,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: r.$5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickLinks() {
    const links = [
      ('Care Plans', Icons.assignment_outlined),
      ('Medication', Icons.medication_outlined),
      ('Care Notes', Icons.note_alt_outlined),
      ('Incident Report', Icons.warning_amber_outlined),
    ];

    return _SectionCard(
      title: 'Quick Links',
      child: Column(
        children: links.map((l) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              onTap: () {
                setState(() => _active = l.$1);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(l.$2, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Small card at the top showing the care worker's shift today.
class _ShiftTodayCard extends StatelessWidget {
  const _ShiftTodayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'My Shift Today',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '7:00 AM - 3:00 PM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Main Care Unit',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple card used for all sections on the dashboard.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// One stat card at the top of the dashboard.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.subLabel,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;
  final String subLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Draws the simple weekly bar chart.
class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.barColor,
    required this.labelColor,
  });

  final List<int> values;
  final List<String> labels;
  final Color barColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double labelHeight = 18;
    final double chartHeight = size.height - labelHeight;
    final int maxValue = values.reduce(math.max);
    final double barWidth = size.width / (values.length * 2);
    final double spacing = (size.width - barWidth * values.length) /
        (values.length + 1);

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < values.length; i++) {
      final double barHeight =
          maxValue == 0 ? 0 : (values[i] / maxValue) * (chartHeight - 8);
      final double x = spacing + i * (barWidth + spacing);
      final double y = chartHeight - barHeight;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: labelColor, fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          chartHeight + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}