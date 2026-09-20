import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/public/home_screen.dart';
import 'screens/public/about_screen.dart';
import 'screens/public/what_we_do_screen.dart';
import 'screens/public/services_screen.dart';
import 'screens/public/contact_screen.dart';
import 'screens/public/company_info_screen.dart';
import 'screens/public/login_screen.dart';
import 'screens/public/accept_invitation_screen.dart';
import 'screens/dashboard/role_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // On Flutter Web, the URL fragment contains the route and query params.
  // Example: http://localhost:5173/#/accept-invitation?token=abc
  final fragment = Uri.base.fragment; // "/accept-invitation?token=abc"
  String? inviteToken;
  if (fragment.startsWith('/accept-invitation')) {
    final parsed = Uri.parse('http://x$fragment');
    inviteToken = parsed.queryParameters['token'];
  }

  runApp(CareManagementApp(initialInviteToken: inviteToken));
}

// Root widget for the whole app.
class CareManagementApp extends StatelessWidget {
  const CareManagementApp({super.key, this.initialInviteToken});

  final String? initialInviteToken;

  @override
  Widget build(BuildContext context) {
    final hasInvite = initialInviteToken != null && initialInviteToken!.isNotEmpty;

    return MaterialApp(
      title: 'CareHome Connect',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: hasInvite
          ? AcceptInvitationScreen(initialToken: initialInviteToken)
          : const HomeScreen(),
      routes: {
        '/about': (_) => const AboutScreen(),
        '/what-we-do': (_) => const WhatWeDoScreen(),
        '/services': (_) => const ServicesScreen(),
        '/contact': (_) => const ContactScreen(),
        '/company-info': (_) => const CompanyInfoScreen(),
        '/login': (_) => const LoginScreen(),
        '/accept-invitation': (_) => const AcceptInvitationScreen(),
        '/dashboard': (_) => const RoleRouter(),
      },
    );
  }
}