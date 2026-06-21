import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';

class TotpVerifyScreen extends StatefulWidget {
  final String challengeToken;
  final String email;
  const TotpVerifyScreen({super.key, required this.challengeToken, required this.email});

  @override
  State<TotpVerifyScreen> createState() => _TotpVerifyScreenState();
}

class _TotpVerifyScreenState extends State<TotpVerifyScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final code = int.tryParse(_codeController.text) ?? 0;
      final token = await api.auth.validateTotpLogin(widget.challengeToken, code);

      await api.auth.saveToken(token.accessToken);
      await api.auth.saveRefreshToken(token.refreshToken);
      await api.auth.saveUserData(
        trackingId: token.trackingId,
        role: token.typeUtilisateur,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code invalide. Réessaie.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vérification'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Icon(Icons.security, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                const Text('Authentification à deux facteurs',
                    style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Entre le code à 6 chiffres généré par ton application d\'authentification.',
                  style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(letterSpacing: 8),
                  validator: (v) => (v == null || v.length != 6) ? 'Code à 6 chiffres' : null,
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Vérifier',
                  isLoading: _isLoading,
                  onPressed: _verify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
