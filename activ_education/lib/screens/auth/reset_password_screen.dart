import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String _email = '';
  String _resetToken = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] ?? '';
      _resetToken = args['resetToken'] ?? '';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  void _submit() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);
    try {
      await ApiService().auth.resetPassword(
        _email,
        _resetToken,
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe réinitialisé avec succès'),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService().handleError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 16),
          ),
        ),
        title: Text(
          'Activ Education',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text('Nouveau mot de passe',
                style: AppTextStyles.displayMedium),
            const SizedBox(height: 10),
            const Text(
              'Choisis un mot de passe sécurisé d\'au moins 8 caractères.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Nouveau mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.textLight, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.textLight, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  child: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_passwordController.text.isNotEmpty &&
                _confirmController.text.isNotEmpty)
              Row(
                children: [
                  Icon(
                    _passwordController.text.length >= 8
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: _passwordController.text.length >= 8
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text('Au moins 8 caractères',
                      style: AppTextStyles.caption.copyWith(
                        color: _passwordController.text.length >= 8
                            ? AppColors.success
                            : AppColors.error,
                      )),
                  const SizedBox(width: 16),
                  Icon(
                    _passwordController.text == _confirmController.text
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: _passwordController.text == _confirmController.text
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text('Les mots de passe correspondent',
                      style: AppTextStyles.caption.copyWith(
                        color: _passwordController.text == _confirmController.text
                            ? AppColors.success
                            : AppColors.error,
                      )),
                ],
              ),

            const SizedBox(height: 32),

            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mot de passe mis à jour',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),

            PrimaryButton(
              label: 'Réinitialiser',
              isLoading: _isLoading,
              onPressed: _isValid ? _submit : null,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
