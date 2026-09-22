import 'package:flutter/material.dart';
import '../widgets/public_header.dart';
import '../widgets/public_footer.dart';
import '../theme.dart';

// Common layout wrapper for all public pages.
class PublicLayout extends StatefulWidget {
  const PublicLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  State<PublicLayout> createState() => _PublicLayoutState();
}

class _PublicLayoutState extends State<PublicLayout> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: isMobile ? _buildDrawer() : null,
      body: Column(
        children: [
          PublicHeader(
            currentRoute: widget.currentRoute,
            onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: widget.child,
            ),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand row at the top of the drawer.
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 22,
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.home_work_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CareHome Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Care . Support . Together',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Navigation items.
            ...PublicHeader.navItems.map((item) {
              final bool active = item.route == widget.currentRoute;
              return ListTile(
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w500,
                    color:
                        active ? AppColors.primary : AppColors.textDark,
                  ),
                ),
                trailing: active
                    ? const Icon(
                        Icons.arrow_right,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context); // close drawer
                  if (item.route == '/') {
                    Navigator.pushReplacementNamed(context, '/');
                  } else {
                    Navigator.pushReplacementNamed(context, item.route);
                  }
                },
              );
            }),
            const Spacer(),
            // Login button at the bottom.
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}