import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import 'admin_dashboard.dart';
import 'manager_dashboard.dart';
import 'care_worker_dashboard.dart';
import 'family_dashboard.dart';

// Picks the correct dashboard based on the user's real role.
class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  final AuthService _auth = AuthService();
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _auth.getCurrentUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user!;

    // The role was set by the backend. Do not trust any role sent from
    // the login page selection.
    switch (user.role) {
      case 'Administrator':
        return AdminDashboard(user: user, onLogout: _logout);
      case 'Manager / Senior Carer':
        return ManagerDashboard(user: user, onLogout: _logout);
      case 'Care Worker':
        return CareWorkerDashboard(user: user, onLogout: _logout);
      case 'Family Member':
        return FamilyDashboard(user: user, onLogout: _logout);
      default:
        // Unknown role. Send back to login.
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 12),
                Text('Unknown role: ${user.role}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        );
    }
  }
}