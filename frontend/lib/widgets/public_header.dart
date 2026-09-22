import 'package:flutter/material.dart';
import '../theme.dart';

// Top navigation bar for all public website pages.
// On wide screens, shows all links. On mobile, shows a hamburger.
class PublicHeader extends StatelessWidget {
  const PublicHeader({
    super.key,
    this.currentRoute,
    this.onMenuTap,
  });

  final String? currentRoute;
  final VoidCallback? onMenuTap;

  static const List<_NavItem> _items = [
    _NavItem('Home', '/'),
    _NavItem('About Us', '/about'),
    _NavItem('What We Do', '/what-we-do'),
    _NavItem('Services', '/services'),
    _NavItem('Contact Us', '/contact'),
    _NavItem('Company Information', '/company-info'),
  ];

  void _goTo(BuildContext context, String route) {
    if (route == '/') {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 14,
      ),
      child: Row(
        children: [
          // Logo.
          InkWell(
            onTap: () => _goTo(context, '/'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_work_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'CareHome Connect',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Care . Support . Together',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 32),
            // Wide screens: inline links.
            Expanded(
              child: Row(
                children: _items.map((item) {
                  final bool active = item.route == currentRoute;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () => _goTo(context, item.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: active
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Login button.
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Login'),
            ),
          ] else ...[
            // Mobile: hamburger on the right.
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary, size: 26),
              onPressed: onMenuTap,
              tooltip: 'Menu',
            ),
          ],
        ],
      ),
    );
  }

  // Used by the layout wrapper to build the mobile drawer.
  static List<_NavItem> get navItems => _items;
}

class _NavItem {
  const _NavItem(this.label, this.route);
  final String label;
  final String route;
}