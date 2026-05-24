import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';
import 'home/dashboard_bachelier.dart';
import 'home/dashboard_reconversion.dart';
import 'home/dashboard_parent.dart';
import 'home/dashboard_conseiller.dart';
import 'explorer/explorer_screen.dart';
import 'diagnostic/quiz_screen.dart';
import 'messages/messages_list_screen.dart';
import 'profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  String? _userRole;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await ApiService().getUserRole();
    if (mounted) setState(() { _userRole = role; _loadingRole = false; });
  }

  Widget _buildDashboard() {
    switch (_userRole?.toUpperCase()) {
      case 'CONSEILLER':
        return const DashboardConseiller();
      case 'PARENT':
        return const DashboardParent();
      case 'RECONVERSION':
        return const DashboardReconversion();
      default:
        return const DashboardBachelier();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _loadingRole ? const SizedBox() : _buildDashboard(),
          const ExplorerScreen(),
          const QuizScreen(),
          const MessagesListScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
