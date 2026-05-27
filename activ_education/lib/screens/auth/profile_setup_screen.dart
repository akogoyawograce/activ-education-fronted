import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

enum UserRole { collegien, lyceen, etudiant, parent, reconversion, decrocheur }

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  UserRole? _selectedRole;
  String? _selectedClass;
  final TextEditingController _cityController = TextEditingController();

  final List<_RoleOption> _roles = [
    const _RoleOption(role: UserRole.collegien, label: 'Collégien(ne)', icon: Icons.school_outlined),
    const _RoleOption(role: UserRole.lyceen, label: 'Lycéen(ne)', icon: Icons.menu_book_outlined),
    const _RoleOption(role: UserRole.etudiant, label: 'Étudiant(e)', icon: Icons.account_balance_outlined),
    const _RoleOption(role: UserRole.parent, label: 'Parent', icon: Icons.people_outline_rounded),
    const _RoleOption(role: UserRole.reconversion, label: 'En reconversion', icon: Icons.work_outline_rounded),
    const _RoleOption(role: UserRole.decrocheur, label: 'Jeune décrocheur', icon: Icons.favorite_border_rounded),
  ];

  final List<String> _collegClasses = ['6ème', '5ème', '4ème', '3ème'];
  final List<String> _lyceeClasses = ['Seconde', 'Première', 'Terminale'];

  List<String> get _availableClasses {
    if (_selectedRole == UserRole.collegien) return _collegClasses;
    if (_selectedRole == UserRole.lyceen) return _lyceeClasses;
    return [];
  }

  bool get _showClassSelector =>
      _selectedRole == UserRole.collegien || _selectedRole == UserRole.lyceen;

  bool get _canContinue =>
      _selectedRole != null &&
      (!_showClassSelector || _selectedClass != null) &&
      _cityController.text.isNotEmpty;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.pushNamed(
      context,
      AppRoutes.register,
      arguments: {
        'role': _selectedRole,
        'class': _selectedClass,
        'city': _cityController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark, size: 20),
                  ),
                  const Spacer(),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 34,
                      height: 34,
                      cacheWidth: 34,
                      cacheHeight: 34,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                  // Step indicator
                  Row(
                    children: [
                      _stepDot(true),
                      const SizedBox(width: 6),
                      _stepDot(false),
                      const SizedBox(width: 6),
                      _stepDot(false),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Dis-nous qui tu es',
                        style: AppTextStyles.displayMedium),
                    const SizedBox(height: 6),
                    const Text(
                      'On personnalisera tout pour toi',
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    const Text('Je suis...', style: AppTextStyles.label),
                    const SizedBox(height: 12),

                    // Role grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: _roles.map((r) => _RoleCard(
                        option: r,
                        isSelected: _selectedRole == r.role,
                        onTap: () {
                          setState(() {
                            _selectedRole = r.role;
                            _selectedClass = null;
                          });
                        },
                      )).toList(),
                    ),

                    // Class selector
                    if (_showClassSelector) ...[
                      const SizedBox(height: 24),
                      const Text('Quelle classe ?', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedClass,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          hint: Text(
                            'Sélectionner une classe',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textLight),
                          ),
                          items: _availableClasses
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedClass = v),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMedium),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Text('Ville de résidence', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cityController,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Lomé, Kara, Sokodé...',
                        prefixIcon: const Icon(Icons.location_on_outlined,
                            color: AppColors.textLight, size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),

            // Continue button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: PrimaryButton(
                label: 'Continuer',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: _canContinue ? _continue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(bool active) {
    return Container(
      width: active ? 20 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.cardBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _RoleOption {
  final UserRole role;
  final String label;
  final IconData icon;
  const _RoleOption(
      {required this.role, required this.label, required this.icon});
}

class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard(
      {required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option.icon,
                    color: isSelected ? AppColors.primary : AppColors.textMedium,
                    size: 26,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.label,
                    style: AppTextStyles.label.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
