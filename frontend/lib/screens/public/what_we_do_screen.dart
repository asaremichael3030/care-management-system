import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/public_hero.dart';
import '../public_layout.dart';

class WhatWeDoScreen extends StatelessWidget {
  const WhatWeDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      currentRoute: '/what-we-do',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PublicHero(
            title: 'What We Do',
            subtitle:
                'Personalised care that puts the resident first, every day.',
            imagePath: 'assets/images/hero_what_we_do.jpg',
          ),
          _buildApproach(),
          _buildCareAreas(),
          _buildEverydayLife(),
        ],
      ),
    );
  }

  Widget _buildApproach() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Our Approach',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Care at CareHome Connect is built around three ideas: knowing the '
            'person, respecting their choices, and supporting their independence. '
            'We do not apply a one-size-fits-all plan. Every resident has a '
            'personal care plan that we review regularly with the resident and '
            'their family.',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareAreas() {
    const areas = [
      (
        Icons.home_outlined,
        'Residential Care',
        'A warm, comfortable home where residents are supported with daily living.',
      ),
      (
        Icons.volunteer_activism_outlined,
        'Personal Care',
        'Help with washing, dressing, and personal hygiene, delivered with dignity.',
      ),
      (
        Icons.medication_outlined,
        'Medication Support',
        'Safe handling and accurate administration of prescribed medication.',
      ),
      (
        Icons.restaurant_outlined,
        'Meals and Nutrition',
        'Freshly prepared meals and support for special dietary needs.',
      ),
      (
        Icons.directions_walk_outlined,
        'Mobility and Wellbeing',
        'Support to move safely and stay as active as possible.',
      ),
      (
        Icons.emoji_people_outlined,
        'Activities and Social Life',
        'A varied programme of activities designed around resident interests.',
      ),
    ];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Areas of Care',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The kind of day-to-day support our team provides.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: areas
                .map((a) => _AreaCard(
                      icon: a.$1,
                      title: a.$2,
                      description: a.$3,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEverydayLife() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A Day in the Home',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          _timelineItem(
            'Morning',
            'Personal care, breakfast, and a gentle start to the day. '
                'Medication is administered on schedule.',
          ),
          _timelineItem(
            'Mid-morning',
            'Activities such as gentle exercise, music, or a group session. '
                'Residents choose whether to join.',
          ),
          _timelineItem(
            'Lunchtime',
            'A freshly cooked meal served in the dining room or in the resident\'s '
                'room if preferred.',
          ),
          _timelineItem(
            'Afternoon',
            'Visiting time, one-to-one conversation, or quiet rest. '
                'Care workers check in regularly.',
          ),
          _timelineItem(
            'Evening',
            'Dinner, a calm wind-down, and personal care before bed. '
                'Night staff are always on duty.',
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(String time, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
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