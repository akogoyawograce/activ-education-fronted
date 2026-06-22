import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';
import 'home/dashboard_bachelier.dart';
import 'home/dashboard_reconversion.dart';
import 'home/dashboard_decrocheur.dart';
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
  String? _typeApprenant;
  bool _loadingRole = true;

  static const _tabsDefaut = [
    NavTab(icon: Icons.home_rounded, iconOutlined: Icons.home_outlined, label: 'Accueil'),
    NavTab(icon: Icons.explore_rounded, iconOutlined: Icons.explore_outlined, label: 'Explorer'),
    NavTab(icon: Icons.quiz_rounded, iconOutlined: Icons.quiz_outlined, label: 'Diagnostic'),
    NavTab(icon: Icons.chat_bubble_rounded, iconOutlined: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    NavTab(icon: Icons.person_rounded, iconOutlined: Icons.person_outline_rounded, label: 'Profil'),
  ];

  static const _tabsParent = [
    NavTab(icon: Icons.home_rounded, iconOutlined: Icons.home_outlined, label: 'Accueil'),
    NavTab(icon: Icons.explore_rounded, iconOutlined: Icons.explore_outlined, label: 'Explorer'),
    NavTab(icon: Icons.chat_bubble_rounded, iconOutlined: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    NavTab(icon: Icons.person_rounded, iconOutlined: Icons.person_outline_rounded, label: 'Profil'),
  ];

  List<NavTab> get _tabs {
    if (_userRole?.toUpperCase() == 'PARENT') return _tabsParent;
    return _tabsDefaut;
  }

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final api = ApiService();
    final role = await api.getUserRole();
    String? type;
    if (role?.toUpperCase() == 'ELEVE') {
      final tid = await api.getTrackingId();
      if (tid != null) {
        try {
          final profile = await api.getEleve(tid);
          type = profile.typeApprenant;
        } catch (_) {}
      }
    }
    if (mounted) setState(() { _userRole = role; _typeApprenant = type; _loadingRole = false; });
  }

  Widget _buildCurrentScreen() {
    final idx = _currentIndex;
    // Parent: [0]Accueil [1]Explorer [2]Messages [3]Profil
    if (_userRole?.toUpperCase() == 'PARENT') {
      switch (idx) {
        case 1: return const ExplorerScreen();
        case 2: return const MessagesListScreen();
        case 3: return const ProfileScreen();
        default: return _loadingRole ? const SizedBox() : _buildDashboard();
      }
    }
    // Défaut: [0]Accueil [1]Explorer [2]Diagnostic [3]Messages [4]Profil
    switch (idx) {
      case 1: return const ExplorerScreen();
      case 2: return const QuizScreen();
      case 3: return const MessagesListScreen();
      case 4: return const ProfileScreen();
      default: return _loadingRole ? const SizedBox() : _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    switch (_userRole?.toUpperCase()) {
      case 'CONSEILLER':
        return const DashboardConseiller();
      case 'PARENT':
        return const DashboardParent();
      default:
        switch (_typeApprenant?.toUpperCase()) {
          case 'PROFESSIONNEL':
            return const DashboardReconversion();
          case 'AUTRE':
            return const DashboardDecrocheur();
          default:
            return DashboardBachelier(typeApprenant: _typeApprenant);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        tabs: _tabs,
      ),
    );
  }
}
