import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsLeft = 45;
  Timer? _timer;
  bool _isLoading = false;
  bool _canResend = false;

  String _type = 'email';
  String _value = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _type = args['type'] ?? 'email';
      _value = args['value'] ?? '';
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 45;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _maskedValue {
    if (_type == 'email') {
      final parts = _value.split('@');
      if (parts.length == 2) {
        final name = parts[0];
        final masked =
            '${name[0]}${'*' * (name.length - 1).clamp(1, 3)}@${parts[1]}';
        return masked;
      }
      return _value;
    } else {
      if (_value.length > 4) {
        return '${_value.substring(0, 4)}${'*' * (_value.length - 4)}';
      }
      return _value;
    }
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _validate() async {
    if (_otp.length < 4) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService().auth.verifyOtp(_value, _otp);
      if (result['success'] == true) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resetPassword,
          arguments: {
            'email': _value,
            'resetToken': result['resetToken'],
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Code invalide')),
          );
        }
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

  void _resendCode() async {
    try {
      await ApiService().auth.forgotPassword(_value);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un nouveau code vous a été envoyé'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark, size: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Vérifie tes messages',
                        style: AppTextStyles.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'On a envoyé un code à $_maskedValue',
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled =
                              _controllers[index].text.isNotEmpty;
                          return Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isFilled
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                                width: isFilled ? 2 : 1.5,
                              ),
                              boxShadow: isFilled
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: AppTextStyles.headingLarge.copyWith(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (v) => _onDigitChanged(index, v),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      if (!_canResend)
                        Text(
                          'Renvoyer le code dans ${_secondsLeft.toString().padLeft(2, '0')}s',
                          style: AppTextStyles.bodyMedium,
                        )
                      else
                        GestureDetector(
                          onTap: _resendCode,
                          child: Text(
                            'Renvoyer le code',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: 'Valider',
                        isLoading: _isLoading,
                        onPressed: _otp.length == 4 ? _validate : null,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'ACTIV EDUCATION',
                        style: AppTextStyles.caption.copyWith(
                          letterSpacing: 2,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
