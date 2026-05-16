import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// Privacy settings widget for differential privacy configuration
class PrivacySettingsWidget extends StatelessWidget {
  final bool enabled;
  final double epsilon;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onEpsilonChanged;

  const PrivacySettingsWidget({
    super.key,
    required this.enabled,
    required this.epsilon,
    required this.onEnabledChanged,
    required this.onEpsilonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.surfaceVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Differential Privacy',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onEnabledChanged,
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (enabled) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Privacy Budget (ε)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            epsilon.toStringAsFixed(2),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: epsilon,
                      min: 0.1,
                      max: 10.0,
                      divisions: 99,
                      label: epsilon.toStringAsFixed(2),
                      onChanged: onEpsilonChanged,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPrivacyLevel(
                          label: 'High Privacy',
                          epsilon: 0.1,
                          isSelected: epsilon < 2,
                          color: Colors.green,
                        ),
                        _buildPrivacyLevel(
                          label: 'Medium Privacy',
                          epsilon: 1.0,
                          isSelected: epsilon >= 2 && epsilon < 5,
                          color: Colors.orange,
                        ),
                        _buildPrivacyLevel(
                          label: 'Low Privacy',
                          epsilon: 10.0,
                          isSelected: epsilon >= 5,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lower ε = More privacy but less accuracy. Higher ε = Better accuracy but less privacy.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Privacy protection disabled. Model updates will be sent without noise.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red.shade700,
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

  Widget _buildPrivacyLevel({
    required String label,
    required double epsilon,
    required bool isSelected,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'ε=$epsilon',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
