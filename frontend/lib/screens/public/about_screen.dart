import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/public_hero.dart';
import '../public_layout.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      currentRoute: '/about',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PublicHero(
            title: 'About Us',
            subtitle:
                'A care home built on dignity, respect, and community.',
            imagePath: 'assets/images/hero_about.jpg',
          ),
          _buildStory(),
          _buildMissionAndValues(),
          _buildTeamOverview(),
        ],
      ),
    );
  }

  Widget _buildStory() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 800;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SectionTitle('Our Story'),
              SizedBox(height: 12),
              Text(
                'CareHome Connect was founded with a simple idea: residents '
                'should live in a place that feels like home, with a team that '
                'treats them like family. Every aspect of our care home is '
                'designed around the person, not the schedule.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'We work closely with residents, their families, and our care '
                'workers to make sure that every day brings comfort, purpose, '
                'and a sense of belonging.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.textDark,
                ),
              ),
            ],
          );

          // Real image on the right. Reuses care_home_hero.jpg which is
          // already in the project. Swap the path for about_story.jpg if
          // you want a dedicated photo here.
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/care_home_hero.jpg',
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  color: AppColors.accent.withOpacity(0.15),
                  child: const Center(
                    child: Icon(
                      Icons.groups_outlined,
                      size: 72,
                      color: AppColors.accent,
                    ),
                  ),
                );
              },
            ),
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: text),
                const SizedBox(width: 32),
                Expanded(child: image),
              ],
            );
          }
          return Column(
            children: [
              text,
              const SizedBox(height: 24),
              image,
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionAndValues() {
    const values = [
      (
        Icons.favorite_border,
        'Compassion',
        'We care with warmth and kindness, always.',
      ),
      (
        Icons.verified_user_outlined,
        'Dignity',
        'Every resident is treated with respect.',
      ),
      (
        Icons.people_outline,
        'Community',
        'Residents, families, and staff are one team.',
      ),
      (
        Icons.shield_outlined,
        'Safety',
        'A secure and comfortable home for everyone.',
      ),
    ];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Our Mission and Values'),
          const SizedBox(height: 8),
          const Text(
            'The principles that guide every decision we make.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: values
                .map((v) => _ValueCard(
                      icon: v.$1,
                      title: v.$2,
                      description: v.$3,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOverview() {
    const roles = [
      ('Care Workers', 'Day-to-day care, companionship, and support.'),
      ('Senior Carers', 'Care planning, medication, and supervision.'),
      ('Managers', 'Operations, family communication, and quality.'),
      ('Administrators', 'Safety, compliance, and system management.'),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Our Care Team'),
          const SizedBox(height: 8),
          const Text(
            'A multi-disciplinary team working together for our residents.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ...roles.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.$1,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          r.$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}