import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/public_hero.dart';
import '../public_layout.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      currentRoute: '/services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PublicHero(
            title: 'Our Services',
            subtitle: 'Personalised care to meet individual needs.',
            imagePath: 'assets/images/care_home_hero.jpg',
          ),
          _buildServicesGrid(),
          _buildWhatIsIncluded(),
          _buildCallToAction(context),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    const services = [
      (
        Icons.home_outlined,
        'Residential Care',
        'A safe and supportive home for residents who need assistance with daily living.',
      ),
      (
        Icons.volunteer_activism_outlined,
        'Personal Care',
        'Respectful help with bathing, dressing, grooming, and personal hygiene.',
      ),
      (
        Icons.medication_outlined,
        'Medication Support',
        'Trained staff to order, store, and administer prescribed medication safely.',
      ),
      (
        Icons.assignment_outlined,
        'Care Planning',
        'Individual care plans created with the resident and their family.',
      ),
      (
        Icons.chat_bubble_outline,
        'Family Communication',
        'Regular updates and simple messaging with the care team.',
      ),
      (
        Icons.emoji_people_outlined,
        'Daily Activities',
        'A varied programme that supports social, physical, and emotional wellbeing.',
      ),
      (
        Icons.restaurant_outlined,
        'Meals and Hydration',
        'Freshly prepared meals with support for special diets and hydration.',
      ),
      (
        Icons.shield_outlined,
        'Risk Management',
        'Careful assessment and prevention of falls, pressure areas, and other risks.',
      ),
      (
        Icons.folder_outlined,
        'Care Documentation',
        'Accurate records of care, medication, and important documents.',
      ),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: services
            .map((s) => _ServiceCard(
                  icon: s.$1,
                  title: s.$2,
                  description: s.$3,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildWhatIsIncluded() {
    const items = [
      'A personal care plan reviewed regularly',
      'A named care worker who knows the resident',
      'Family communication through the app',
      'Regular wellbeing and health reviews',
      'A daily activity programme',
      'Support with appointments',
      'A secure, comfortable private room',
      'Nutritional meals prepared on site',
    ];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is Included',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Every resident has access to the following as part of our care.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((i) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      i,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interested in our services?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get in touch to arrange a visit or ask a question.',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/contact');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
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
      width: 260,
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