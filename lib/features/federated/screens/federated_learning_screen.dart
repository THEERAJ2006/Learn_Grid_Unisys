import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../ai/federated_learning/fl_providers.dart';
import '../widgets/fl_stats_card.dart';
import '../widgets/privacy_settings_widget.dart';

/// Federated Learning Training Screen
/// Displays local training progress, round status, and privacy settings
class FederatedLearningScreen extends ConsumerStatefulWidget {
  const FederatedLearningScreen({super.key});

  @override
  ConsumerState<FederatedLearningScreen> createState() =>
      _FederatedLearningScreenState();
}

class _FederatedLearningScreenState
    extends ConsumerState<FederatedLearningScreen> {
  bool _isTraining = false;
  int _currentRound = 1;
  final int _totalRounds = 5;

  Future<void> _startTraining() async {
    setState(() => _isTraining = true);

    try {
      final flClient = ref.read(flClientProvider);
      
      // Simulate training data (in real app, fetch from database)
      final features = List<List<double>>.generate(100, (i) {
        return List<double>.generate(10, (j) => (i + j).toDouble() / 100);
      });
      final labels = List<int>.generate(100, (i) => i % 5);

      // Perform local training
      final accuracy = await flClient.trainLocal(
        features: features,
        labels: labels,
        epochs: 3,
        learningRate: 0.01,
      );

      // Update providers
      ref.read(flLocalAccuracyProvider.notifier).state = accuracy;
      ref.read(flRoundProvider.notifier).state = _currentRound;

      // Compute gradients
      final gradients = await flClient.computeGradientUpdate();

      // Apply differential privacy
      await flClient.applyDifferentialPrivacy(gradients);

      setState(() {
        _isTraining = false;
        if (_currentRound < _totalRounds) _currentRound++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Training complete! Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isTraining = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Training error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(flRoundProvider);
    final flAccuracy = ref.watch(flLocalAccuracyProvider);
    final privacyEnabled = ref.watch(flPrivacyEnabledProvider);
    final epsilon = ref.watch(flEpsilonProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Federated Learning',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Training Status Card
              _buildTrainingStatusCard(),
              const SizedBox(height: 24),

              // Round Progress
              _buildRoundProgress(),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsSection(flAccuracy),
              const SizedBox(height: 24),

              // Privacy Settings
              PrivacySettingsWidget(
                enabled: privacyEnabled,
                epsilon: epsilon,
                onEnabledChanged: (enabled) {
                  ref.read(flPrivacyEnabledProvider.notifier).state = enabled;
                },
                onEpsilonChanged: (value) {
                  ref.read(flEpsilonProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 24),

              // Training Button
              _buildTrainingSection(),
              const SizedBox(height: 24),
            ],
          ).animate().fadeIn(),
        ),
      ),
    );
  }

  Widget _buildTrainingStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Training Status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isTraining ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isTraining ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isTraining ? 'Training...' : 'Ready',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isTraining ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isTraining)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Training in progress...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            )
          else
            Text(
              'Ready to start local training on your device',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoundProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Round Progress',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Round $_currentRound / $_totalRounds',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${((_currentRound / _totalRounds) * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _currentRound / _totalRounds,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
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

  Widget _buildStatsSection(double? accuracy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FLStatsCard(
                  label: 'Local Accuracy',
                  value: accuracy != null
                      ? '${(accuracy * 100).toStringAsFixed(1)}%'
                      : 'N/A',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FLStatsCard(
                  label: 'Round',
                  value: '$_currentRound',
                  icon: Icons.repeat,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Controls',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTraining ? null : _startTraining,
              icon: Icon(_isTraining ? Icons.hourglass_empty : Icons.play_arrow),
              label: Text(_isTraining ? 'Training...' : 'Start Local Training'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTraining ? Colors.grey : AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Local training uses synthetic data. In production, real learning data would be used.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.blue.shade700,
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
