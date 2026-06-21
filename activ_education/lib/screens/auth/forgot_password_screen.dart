import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _useEmail = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    final value = _useEmail ? _emailController.text : _phoneController.text;
    if (value.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ApiService().auth.forgotPassword(value);
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.otp,
          arguments: {
            'type': _useEmail ? 'email' : 'phone',
            'value': value,
          },
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
            const Text('Mot de passe oublié ?',
                style: AppTextStyles.displayMedium),
            const SizedBox(height: 10),
            const Text(
              'Saisis ton email ou ton numéro de téléphone. On t\'envoie un code de réinitialisation.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Toggle Email / Téléphone
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _ToggleButton(
                    label: 'Email',
                    isActive: _useEmail,
                    onTap: () => setState(() => _useEmail = true),
                  ),
                  _ToggleButton(
                    label: 'Téléphone',
                    isActive: !_useEmail,
                    onTap: () => setState(() => _useEmail = false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Champ input
            if (_useEmail)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Saisis ton email',
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: AppColors.textLight, size: 20),
                ),
              )
            else
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: '+228 XX XX XX XX',
                  prefixIcon: Icon(Icons.phone_outlined,
                      color: AppColors.textLight, size: 20),
                ),
              ),

            const SizedBox(height: 24),

            // Illustration
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
                      _useEmail
                          ? 'Un lien sera envoyé à ton email'
                          : 'Un SMS sera envoyé à ce numéro',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),

            PrimaryButton(
              label: 'Envoyer le code',
              isLoading: _isLoading,
              trailingIcon: Icons.send_rounded,
              onPressed: _sendCode,
            ),

            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary, size: 18),
                    Text(
                      'Retour à la connexion',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? Colors.white : AppColors.textMedium,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
