import 'package:flutter/material.dart';
import '../../theme.dart';
import '../public_layout.dart';

// Public home page.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_Service> _services = [
    _Service('Residential Care', 'A safe and supportive environment.',
        Icons.home_outlined),
    _Service('Personal Care', 'Support with daily activities.',
        Icons.volunteer_activism_outlined),
    _Service('Medication Support', 'Accurate medication schedules.',
        Icons.medication_outlined),
    _Service('Care Planning', 'Individual care plans for every resident.',
        Icons.assignment_outlined),
    _Service('Family Communication', 'Families informed and involved.',
        Icons.chat_bubble_outline),
    _Service('Daily Activities', 'Social, wellbeing and independence.',
        Icons.emoji_people_outlined),
  ];

  static const List<_Reason> _reasons = [
    _Reason('Compassionate Care', 'We put residents first.',
        Icons.favorite_border),
    _Reason('Qualified Care Team', 'Experienced and caring staff.',
        Icons.groups_outlined),
    _Reason('Safe Environment', 'A secure and comfortable home.',
        Icons.shield_outlined),
    _Reason('Individual Care Plans', 'Tailored to each resident.',
        Icons.description_outlined),
    _Reason('Family Communication', 'Regular updates and support.',
        Icons.forum_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      currentRoute: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHero(context),
          _buildServices(),
          _buildWhyChooseUs(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 900;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quality Care in a Safe\nand Supportive Home',
                style: TextStyle(
                  fontSize: 40,
                  height: 1.15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Providing compassionate care, support and a comfortable '
                'environment for residents and their families.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/services');
                    },
                    child: const Text('Learn More'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/contact');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Contact Us'),
                  ),
                ],
              ),
            ],
          );

          final right = ClipRRect(
           borderRadius: BorderRadius.circular(16),
           child: Image.asset(
            'assets/images/care_home_hero.jpg',
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: left),
                const SizedBox(width: 32),
                Expanded(child: right),
              ],
            );
          }

          return Column(
            children: [
              left,
              const SizedBox(height: 24),
              right,
            ],
          );
        },
      ),
    );
  }

  Widget _buildServices() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Personalised care to meet individual needs.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children:
                _services.map((s) => _ServiceCard(service: s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: _reasons.map((r) => _ReasonChip(reason: r)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final _Service service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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
            child: Icon(service.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({required this.reason});
  final _Reason reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(reason.icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reason.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              reason.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Service {
  const _Service(this.title, this.description, this.icon);
  final String title;
  final String description;
  final IconData icon;
}

class _Reason {
  const _Reason(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}