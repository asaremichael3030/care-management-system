import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/public_hero.dart';
import '../public_layout.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      currentRoute: '/company-info',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PublicHero(
            title: 'Company Information',
            subtitle:
                'Details about the organisation that operates CareHome Connect.',
            imagePath: 'assets/images/hero_company_info.jpg',
          ),
          _buildCompanyDetails(),
          _buildPolicies(),
          _buildRegulatory(),
        ],
      ),
    );
  }

  Widget _buildCompanyDetails() {
    const rows = [
      ('Registered Name', 'CareHome Connect Ltd'),
      ('Registration Number', '00000000'),
      ('Registered Address', '123 Care Home Road, Your Town, Your County, Postal Code'),
      ('Country', 'United Kingdom'),
      ('Main Contact', 'hello@carehomeconnect.com'),
      ('Main Telephone', '+44 20 0000 0000'),
      ('VAT Number', 'GB 000 0000 00'),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registered Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: rows
                  .map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 180,
                              child: Text(
                                r.$1,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                r.$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicies() {
    const policies = [
      (
        'Privacy Policy',
        'How we collect, use, and protect personal information about residents, families, and staff.'
      ),
      (
        'Safeguarding Policy',
        'Our commitment to protecting the safety and wellbeing of every resident.'
      ),
      (
        'Equality and Diversity Policy',
        'Our commitment to treating every person with fairness, dignity, and respect.'
      ),
      (
        'Complaints Procedure',
        'How to raise a concern and what happens after you do.'
      ),
      (
        'Data Protection',
        'How we comply with GDPR and data protection law.'
      ),
      (
        'Health and Safety Policy',
        'How we keep the care home safe for residents, visitors, and staff.'
      ),
    ];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Policies',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Written copies of any policy are available on request at the care home.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ...policies.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.$2,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
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
          ),
        ],
      ),
    );
  }

  Widget _buildRegulatory() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Regulatory Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'CareHome Connect is regulated by the relevant care regulator for '
            'its area. Our latest inspection report and registration certificate '
            'are available on request from the care home manager.',
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'If you would like a copy of any of the documents listed above, '
            'please contact us through the Contact Us page.',
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}