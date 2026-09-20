import 'package:flutter/material.dart';
import '../theme.dart';

// A reusable hero banner with a background image and a colored overlay.
// Used at the top of every public page.
class PublicHero extends StatelessWidget {
  const PublicHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.height = 300,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image. Falls back to a solid color if the image
          // file is missing, so the page never breaks.
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: AppColors.primaryDark);
            },
          ),
          // Dark gradient overlay for readable text.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark.withOpacity(0.80),
                  AppColors.primary.withOpacity(0.55),
                ],
              ),
            ),
          ),
          // Text content on top.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}