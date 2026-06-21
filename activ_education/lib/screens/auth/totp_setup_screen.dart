import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';

class TotpSetupScreen extends StatefulWidget {
  const TotpSetupScreen({super.key});

  @override
  State<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends State<TotpSetupScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _secretKey;
  String? _qrUri;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final api = ApiService();
      _isEnabled = await api.auth.getTotpStatus();
      if (!_isEnabled) {
        final data = await api.auth.generateTotp();
        _secretKey = data['secretKey'];
        _qrUri = data['qrUri'];
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isVerifying = true);
    try {
      final code = int.tryParse(_codeController.text) ?? 0;
      final success = await ApiService().auth.verifyTotp(code);
      if (success && mounted) {
        setState(() => _isEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentification à deux facteurs activée')),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code invalide. Vérifie et réessaie.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la vérification')),
        );
      }
    }
    if (mounted) setState(() => _isVerifying = false);
  }

  Future<void> _disable() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver la 2FA ?'),
        content: const Text('Cela réduit la sécurité de ton compte.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Désactiver')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService().auth.disableTotp();
      if (mounted) {
        setState(() => _isEnabled = false);
        final data = await ApiService().auth.generateTotp();
        _secretKey = data['secretKey'];
        _qrUri = data['qrUri'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA désactivée')),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sécurité du compte'),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _isEnabled ? _buildEnabledView() : _buildSetupView(),
            ),
    );
  }

  Widget _buildEnabledView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.shield, size: 80, color: AppColors.success),
        const SizedBox(height: 16),
        const Text('Authentification à deux facteurs activée',
            style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Ta session est protégée par un code supplémentaire.',
            style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _disable,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('Désactiver la 2FA'),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.security, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text('Active la double authentification',
            style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text(
          'Scanne le code dans ton application d\'authentification (Google Authenticator, Authy...) ou saisis la clé manuellement.',
          style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (_qrUri != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text('Clé secrète : $_secretKey',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                SelectableText(_qrUri!,
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Code de vérification', style: AppTextStyles.headingMedium),
        ),
        const SizedBox(height: 8),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (v) => (v == null || v.length != 6) ? 'Code à 6 chiffres' : null,
            decoration: const InputDecoration(
              hintText: '000000',
              prefixIcon: Icon(Icons.pin),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Activer la 2FA',
          isLoading: _isVerifying,
          onPressed: _verify,
        ),
      ],
    );
  }
}
