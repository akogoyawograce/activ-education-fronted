import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';

// ─── Primary Button (Orange) ───────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.buttonText),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, color: Colors.white, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─── Outline Button (Blue) ─────────────────────────────────────────────────
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const OutlineButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ─── App Text Field ────────────────────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? prefixText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixText: widget.prefixText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textLight, size: 18)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// ─── Dot Indicator (Onboarding) ────────────────────────────────────────────
class DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const DotIndicator({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Divider with text ─────────────────────────────────────────────────────
class DividerWithText extends StatelessWidget {
  final String text;
  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.cardBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: AppColors.cardBorder)),
      ],
    );
  }
}

// ─── Auth Image (with JWT header) ──────────────────────────────────────────
class AuthImage extends StatefulWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AuthImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.loadingBuilder,
    this.errorBuilder,
  });

  /// Call on logout to clear the cached JWT token
  static void clearTokenCache() => _AuthImageState.clearTokenCache();

  @override
  State<AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends State<AuthImage> {
  static String? _cachedToken;
  static bool _tokenLoaded = false;
  static Future<void>? _tokenFuture;

  @override
  void initState() {
    super.initState();
    _ensureToken();
  }

  static void clearTokenCache() {
    _cachedToken = null;
    _tokenLoaded = false;
    _tokenFuture = null;
  }

  static Future<void> _ensureToken() async {
    if (_tokenLoaded) return;
    if (_tokenFuture != null) return _tokenFuture;
    _tokenFuture = () async {
      try {
        const storage = FlutterSecureStorage();
        _cachedToken = await storage.read(key: 'auth_token');
      } catch (_) {
        _cachedToken = null;
      }
      _tokenLoaded = true;
    }();
    return _tokenFuture;
  }

  @override
  Widget build(BuildContext context) {
    final url = resolveImageUrl(widget.imageUrl);
    if (url == null) return const SizedBox.shrink();

    if (!_tokenLoaded) {
      return _placeholder();
    }

    final headers = _cachedToken != null ? {'Authorization': 'Bearer $_cachedToken'} : null;
    final cacheH = widget.height != null && widget.height!.isFinite ? widget.height!.toInt() : null;

    return Image.network(
      url,
      height: widget.height,
      width: widget.width,
      cacheHeight: cacheH,
      fit: widget.fit,
      headers: headers,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder ?? (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: AppColors.cardBorder.withValues(alpha: 0.2),
      child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textLight, size: 32)),
    );
  }
}

// ─── Step Progress Bar ─────────────────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final done = i < currentStep;
        final active = i == currentStep - 1;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: done || active ? AppColors.primary : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
