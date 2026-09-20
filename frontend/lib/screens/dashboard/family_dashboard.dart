import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../models/user.dart';
import '../../services/family_service.dart';
import '../../theme.dart';
import '../care_notes/care_notes_screen.dart';
import '../care_plans/care_plans_screen.dart';
import '../medications/medications_screen.dart';
import 'dashboard_layout.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../documents/documents_screen.dart';
import '../family/activities_screen.dart';
import '../family/care_team_screen.dart';
import '../family/contact_care_home_screen.dart';
import '../family/my_relative_screen.dart';
import '../settings/settings_screen.dart';

class FamilyDashboard extends StatefulWidget {
  const FamilyDashboard({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  State<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends State<FamilyDashboard> {
  static const List<DashboardNavItem> _navItems = [
    DashboardNavItem('Dashboard', Icons.dashboard_outlined),
    DashboardNavItem('My Relative', Icons.person_outline),
    DashboardNavItem('Care Plan', Icons.assignment_outlined),
    DashboardNavItem('Medication', Icons.medication_outlined),
    DashboardNavItem('Care Updates', Icons.update_outlined),
    DashboardNavItem('Activities', Icons.emoji_people_outlined),
    DashboardNavItem('Care Team', Icons.groups_outlined),
    DashboardNavItem('Messages', Icons.chat_bubble_outline),
    DashboardNavItem('Notifications', Icons.notifications_none),
    DashboardNavItem('Documents', Icons.folder_outlined),
    DashboardNavItem('Contact Care Home', Icons.call_outlined),
    DashboardNavItem('Settings', Icons.settings_outlined),
  ];

  String _active = 'Dashboard';

  final FamilyService _familyService = FamilyService();
  Resident? _linkedResident;
  bool _loadingRelative = true;

  @override
  void initState() {
    super.initState();
    _loadRelative();
  }

  Future<void> _loadRelative() async {
    try {
      final list = await _familyService.myRelative();
      if (!mounted) return;
      setState(() {
        _linkedResident = list.isNotEmpty ? list.first : null;
        _loadingRelative = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRelative = false);
    }
  }

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
      case 'Care Plan':
        return _linkedResident == null
            ? const DashboardPlaceholder(title: 'No relative linked yet')
            : CarePlansScreen(
                currentUser: widget.user,
                residentId: _linkedResident!.id,
              );
      case 'Medication':
        return _linkedResident == null
            ? const DashboardPlaceholder(title: 'No relative linked yet')
            : MedicationsScreen(
                currentUser: widget.user,
                residentId: _linkedResident!.id,
              );
      case 'Care Updates':
        return _linkedResident == null
            ? const DashboardPlaceholder(title: 'No relative linked yet')
            : CareNotesScreen(
                currentUser: widget.user,
                residentId: _linkedResident!.id,
              );
      case 'Messages':
        return MessagesScreen(currentUser: widget.user);
      case 'Notifications':
        return NotificationsScreen(currentUser: widget.user);
      case 'Documents':
        return _linkedResident == null
      ? const DashboardPlaceholder(title: 'No relative linked yet')
      : DocumentsScreen(
          currentUser: widget.user,
          residentId: _linkedResident!.id,
        );
      case 'My Relative':
        return MyRelativeScreen(currentUser: widget.user);
      case 'Activities':
        return ActivitiesScreen(currentUser: widget.user);
      case 'Care Team':
        return const CareTeamScreen();
      case 'Contact Care Home':
  return const ContactCareHomeScreen();
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
          // Greeting and linked relative header.
          LayoutBuilder(
            builder: (context, constraints) {
              final greeting = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${widget.user.firstName}.',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Here is the latest update on your relative.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              );

              final relativeCard = _RelativeHeaderCard(
                resident: _linkedResident,
                loading: _loadingRelative,
              );

              if (constraints.maxWidth >= 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: greeting),
                    const SizedBox(width: 16),
                    relativeCard,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  greeting,
                  const SizedBox(height: 16),
                  relativeCard,
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
                  _FamilyStatCard(
                    width: cardWidth,
                    icon: Icons.person_outline,
                    title: 'My Relative',
                    subtitle: 'View resident details',
                    color: AppColors.primary,
                  ),
                  _FamilyStatCard(
                    width: cardWidth,
                    icon: Icons.chat_bubble_outline,
                    title: 'Messages',
                    subtitle: '3 new messages',
                    color: AppColors.accent,
                  ),
                  _FamilyStatCard(
                    width: cardWidth,
                    icon: Icons.update_outlined,
                    title: 'Care Updates',
                    subtitle: 'Latest care notes',
                    color: AppColors.warning,
                  ),
                  _FamilyStatCard(
                    width: cardWidth,
                    icon: Icons.medication_outlined,
                    title: 'Medication',
                    subtitle: 'View medication schedule',
                    color: AppColors.success,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Care team and care plan progress.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildCareTeam()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCarePlanProgress()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildCareTeam(),
                  const SizedBox(height: 16),
                  _buildCarePlanProgress(),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Upcoming activities and recent care notes.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildUpcomingActivities()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRecentCareNotes()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildUpcomingActivities(),
                  const SizedBox(height: 16),
                  _buildRecentCareNotes(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCareTeam() {
    const members = [
      (
        'Sarah Williams',
        'Care Worker',
        Icons.phone_outlined,
        Icons.mail_outline,
      ),
      (
        'James Brown',
        'Manager / Senior Carer',
        Icons.phone_outlined,
        Icons.mail_outline,
      ),
    ];

    return _SectionCard(
      title: "Your Relative's Care Team",
      child: Column(
        children: members.map((m) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    m.$1.split(' ').last.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.$1,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.$2,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _IconActionButton(icon: m.$3),
                const SizedBox(width: 8),
                _IconActionButton(icon: m.$4),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCarePlanProgress() {
    const double progress = 0.85;

    return _SectionCard(
      title: 'Care Plan Progress',
      child: Column(
        children: [
          SizedBox(
            height: 130,
            width: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(130, 130),
                  painter: _CircularProgressPainter(
                    progress: progress,
                    backgroundColor: AppColors.border,
                    progressColor: AppColors.primary,
                    strokeWidth: 12,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Today's care tasks completed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _linkedResident == null
                  ? null
                  : () => setState(() => _active = 'Care Plan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'View Care Plan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActivities() {
    return _SectionCard(
      title: 'Upcoming Activities',
      trailing: TextButton(
        onPressed: () {
          // Activities module arrives in a later step.
        },
        child: const Text(
          'View All',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Family Visit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Saturday, 2:00 PM',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Room 12',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCareNotes() {
    return _SectionCard(
      title: 'Recent Care Notes',
      trailing: TextButton(
        onPressed: _linkedResident == null
            ? null
            : () => setState(() => _active = 'Care Updates'),
        child: const Text(
          'View All',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Open Care Updates to view the latest notes.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

// Header card showing the linked relative.
class _RelativeHeaderCard extends StatelessWidget {
  const _RelativeHeaderCard({required this.resident, required this.loading});
  final Resident? resident;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (resident == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
            SizedBox(width: 8),
            Text(
              'No relative linked to your account yet.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final r = resident!;
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
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(
              r.firstName.isNotEmpty ? r.firstName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.meeting_room_outlined,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Room ${r.room ?? '-'}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.status.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Family dashboard stat card: icon on top left, title, subtitle.
class _FamilyStatCard extends StatelessWidget {
  const _FamilyStatCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// Small circular icon button used for phone and email.
class _IconActionButton extends StatelessWidget {
  const _IconActionButton({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 14, color: AppColors.primary),
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

// Draws the circular progress ring for the Care Plan Progress panel.
class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}