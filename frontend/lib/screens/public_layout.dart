import 'package:flutter/material.dart';
import '../widgets/public_header.dart';
import '../widgets/public_footer.dart';
import '../theme.dart';

// Common layout wrapper for all public pages.
class PublicLayout extends StatelessWidget {
  const PublicLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PublicHeader(currentRoute: currentRoute),
          Expanded(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
          const PublicFooter(),
        ],
      ),
    );
  }
}