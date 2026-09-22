import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../theme.dart';

// One sidebar entry. Each dashboard passes its own list of these.
class DashboardNavItem {
  final String label;
  final IconData icon;
  const DashboardNavItem(this.label, this.icon);
}

// Shared sidebar and header used by all four role dashboards.
// On narrow screens, the sidebar becomes a drawer.
class DashboardLayout extends StatelessWidget {
  const DashboardLayout({
    super.key,
    required this.user,
    required this.navItems,
    required this.activeItem,
    required this.onSelect,
    required this.onLogout,
    required this.child,
  });

  final User user;
  final List<DashboardNavItem> navItems;
  final String activeItem;
  final ValueChanged<String> onSelect;
  final VoidCallback onLogout;
  final Widget child;

  // Width at which the layout switches between drawer and fixed sidebar.
  static const double _mobileBreakpoint = 800;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = width >= _mobileBreakpoint;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _buildSidebar(context, isMobile: false),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout: AppBar with hamburger opens the sidebar as a drawer.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'CareHome Connect',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: _buildSidebar(context, isMobile: true),
      ),
      body: child,
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isMobile}) {
    return Container(
      width: isMobile ? null : 220,
      color: AppColors.primaryDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand row (hidden on mobile because the AppBar already has it).
            if (!isMobile)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.home_work_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CareHome Connect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Care . Support . Together',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Navigation.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: navItems
                    .map((item) => _buildNavTile(context, item, isMobile))
                    .toList(),
              ),
            ),

            // Logout.
            InkWell(
              onTap: () {
                if (isMobile) Navigator.of(context).pop();
                onLogout();
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 16),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(
      BuildContext context, DashboardNavItem item, bool isMobile) {
    final bool active = item.label == activeItem;
    return InkWell(
      onTap: () {
        // Close the drawer on mobile before switching pages.
        if (isMobile) Navigator.of(context).pop();
        onSelect(item.label);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: Colors.white, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wide screen only header.
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          // Search.
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User info.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                user.role,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              user.firstName.isNotEmpty
                  ? user.firstName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple placeholder shown for pages that arrive in a later step.
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        '$title page arrives in a later step.',
        style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
      ),
    );
  }
}