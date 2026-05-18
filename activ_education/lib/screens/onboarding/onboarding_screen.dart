import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _animController.reset();
                  _animController.forward();
                },
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                ],
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  DotIndicator(count: 3, current: _currentPage),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _currentPage < 2 ? 'Suivant' : 'Commencer',
                    onPressed: _nextPage,
                    trailingIcon: _currentPage < 2 ? null : Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: 16),
                  if (_currentPage < 2)
                    GestureDetector(
                      onTap: _skip,
                      child: Text(
                        'Passer',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _skip,
                      child: RichText(
                        text: TextSpan(
                          text: "J'ai déjà un compte  ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMedium,
                          ),
                          children: [
                            TextSpan(
                              text: 'Se connecter',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Découvre ta voie ──────────────────────────────────────────────
class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Illustration — paths diagram
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _PathDiagramPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const Spacer(flex: 2),
          const Text(
            'Découvre ta voie',
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Explore les séries, filières et métiers qui te correspondent vraiment',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ─── Page 2: Diagnostic ────────────────────────────────────────────────────
class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Illustration — quiz mockup
          SizedBox(
            height: 220,
            child: _QuizMockupIllustration(),
          ),
          const Spacer(flex: 2),
          const Text(
            'Un diagnostic fait pour toi',
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Quiz d\'orientation intelligent + analyse de tes notes. Des recommandations réelles basées sur le système togolais.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ─── Page 3: Conseiller ────────────────────────────────────────────────────
class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            height: 220,
            child: _ConseillerIllustration(),
          ),
          const Spacer(flex: 2),
          const Text(
            'Un conseiller près de toi',
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Pose tes questions, prends rendez-vous. Des conseillers formés au contexte togolais répondent sous 48h.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ─── Custom Painter: Path diagram (page 1) ─────────────────────────────────
class _PathDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paintBlue = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintOrange = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Center bottom dot
    canvas.drawCircle(
      Offset(cx, cy + 50),
      10,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );

    // Left branch (blue)
    final pathLeft = Path()
      ..moveTo(cx, cy + 50)
      ..cubicTo(cx - 20, cy, cx - 60, cy - 30, cx - 80, cy - 60);
    canvas.drawPath(pathLeft, paintBlue);

    // Right branch (blue)
    final pathRight = Path()
      ..moveTo(cx, cy + 50)
      ..cubicTo(cx + 20, cy, cx + 60, cy - 30, cx + 80, cy - 60);
    canvas.drawPath(pathRight, paintBlue);

    // Center branch (orange)
    final pathCenter = Path()
      ..moveTo(cx, cy + 50)
      ..lineTo(cx, cy - 60);
    canvas.drawPath(pathCenter, paintOrange);

    // Left circle
    canvas.drawCircle(
      Offset(cx - 80, cy - 60),
      28,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx - 80, cy - 60),
      28,
      paintBlue,
    );

    // Center circle (orange, larger)
    canvas.drawCircle(
      Offset(cx, cy - 70),
      32,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(Offset(cx, cy - 70), 32, paintOrange);

    // Right circle
    canvas.drawCircle(
      Offset(cx + 80, cy - 60),
      28,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(Offset(cx + 80, cy - 60), 28, paintBlue);

    // Icons inside circles (simplified)
    final iconPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // graduation cap left
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 80, cy - 62), width: 18, height: 14),
        const Radius.circular(2),
      ),
      iconPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Quiz Mockup Illustration ──────────────────────────────────────────────
class _QuizMockupIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone mockup
          Container(
            width: 170,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 12),
                const _MockOption(isSelected: false),
                const SizedBox(height: 8),
                const _MockOption(isSelected: true),
                const SizedBox(height: 8),
                const _MockOption(isSelected: false),
              ],
            ),
          ),
          // Star badge
          Positioned(
            top: 10,
            right: 20,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
            ),
          ),
          // Analytics badge
          Positioned(
            top: 60,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
            ),
          ),
          // School badge
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockOption extends StatelessWidget {
  final bool isSelected;
  const _MockOption({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.textLight,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 6,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.4) : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conseiller Illustration ───────────────────────────────────────────────
class _ConseillerIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Person avatar
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
          // Simplified person
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 34),
              ),
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
              ),
            ],
          ),
          // Chat bubble (left)
          Positioned(
            left: 0,
            top: 40,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 22),
            ),
          ),
          // Camera (top right)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.videocam_outlined, color: Colors.white, size: 20),
            ),
          ),
          // Phone (right middle)
          Positioned(
            right: 0,
            top: 70,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
