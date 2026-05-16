import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/settings_prefs.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: [
            _buildPage(
              icon: Icons.smartphone,
              title: 'Welcome to LearnGrid',
              subtitle: 'Offline-first learning with on-device AI',
              body: 'LearnGrid works completely offline. Download once, learn anywhere—no internet required!',
              color: Colors.blue,
            ),
            _buildPage(
              icon: Icons.security,
              title: 'Your Data, Your Privacy',
              subtitle: 'Private learning, private progress',
              body: 'Your learning data stays on your device. We never track your learning without explicit consent.',
              color: Colors.purple,
            ),
            _buildPage(
              icon: Icons.cloud,
              title: 'Optional Cloud AI',
              subtitle: 'When you want it',
              body: 'Connect to cloud AI (Gemini, Groq) for advanced features. Always your choice.',
              color: Colors.orange,
            ),
            _buildPage(
              icon: Icons.trending_up,
              title: 'Track Your Progress',
              subtitle: 'Visualize your learning journey',
              body: 'Built-in analytics show your progress, streaks, and learning patterns.',
              color: Colors.green,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppTheme.background,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Buttons
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (_currentPage < 3) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        await SettingsPrefs.setHasShownOnboarding(true);
                        if (context.mounted) context.go('/');
                      }
                    },
                    child: Text(_currentPage < 3 ? 'Next' : 'Get Started'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await SettingsPrefs.setHasShownOnboarding(true);
                  if (context.mounted) context.go('/');
                },
                child: const Text('Skip for now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required String body,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Icon in colored circle
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 50, color: color),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.7, 0.7)),
          const SizedBox(height: 40),
          // Title
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 150.ms)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 150.ms),
          const SizedBox(height: 24),
          // Body text
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade300,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 200.ms),
          const Spacer(),
          // Feature bullets (for first page only)
          if (title == 'Welcome to LearnGrid') ...[
            _OnboardingBullet(
              icon: Icons.check_circle,
              text: 'Works fully offline',
              delay: 300,
            ),
            const SizedBox(height: 16),
            _OnboardingBullet(
              icon: Icons.shield,
              text: 'Tracks progress privately',
              delay: 400,
            ),
            const SizedBox(height: 16),
            _OnboardingBullet(
              icon: Icons.cloud_upload,
              text: 'Optional cloud AI only with consent',
              delay: 500,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Onboarding bullet ─────────────────────────────────────────────────

class _OnboardingBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _OnboardingBullet({
    required this.icon,
    required this.text,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 20,
            color: Colors.green.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade300,
              height: 1.4,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay))
        .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: Duration(milliseconds: delay));
  }
}
