import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../providers/message_provider.dart';
import '../utils/theme.dart';
import '../widgets/threat_level_card.dart';
import '../widgets/security_metrics_card.dart';
import '../widgets/quick_analyze_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('McAfee Security Analyzer'),
        backgroundColor: AppTheme.mcafeeDarkBlue,
      ),
      body: Consumer2<SecurityProvider, MessageProvider>(
        builder: (context, securityProvider, messageProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(context),
                const SizedBox(height: 24),
                
                // Quick Analyze Section
                QuickAnalyzeCard(
                  onAnalyze: (message, sender) {
                    messageProvider.updateCurrentMessage(message);
                    messageProvider.updateCurrentSender(sender);
                    securityProvider.analyzeMessage(message, sender: sender);
                  },
                ),
                const SizedBox(height: 24),
                
                // Current Threat Level
                if (securityProvider.currentAnalysis != null)
                  ThreatLevelCard(
                    analysis: securityProvider.currentAnalysis!,
                  ),
                const SizedBox(height: 24),
                
                // Security Metrics
                SecurityMetricsCard(
                  statistics: securityProvider.getThreatStatistics(),
                ),
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(context, securityProvider),
                const SizedBox(height: 24),
                
                // Security Tips
                _buildSecurityTips(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.mcafeeDarkBlue,
            AppTheme.mcafeeBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.security,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Protecting your messages from threats',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusIndicator('Real-time Scanning', true),
              const SizedBox(width: 16),
              _buildStatusIndicator('Threat Detection', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.safeGreen : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, SecurityProvider securityProvider) {
    final recentAnalyses = securityProvider.analysisHistory.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppTheme.mcafeeDarkBlue),
                const SizedBox(width: 8),
                const Text(
                  'Recent Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to history screen
                    DefaultTabController.of(context)?.animateTo(2);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentAnalyses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No messages analyzed yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentAnalyses.map(
                (analysis) => _buildRecentActivityItem(context, analysis),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityItem(BuildContext context, analysis) {
    Color threatColor = AppTheme.getThreatColor(analysis.threatScore);
    String threatText = AppTheme.getThreatDescription(analysis.threatScore);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: threatColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.messageContent.length > 50
                      ? '${analysis.messageContent.substring(0, 50)}...'
                      : analysis.messageContent,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  threatText,
                  style: TextStyle(
                    fontSize: 12,
                    color: threatColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(analysis.analyzedAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTips(BuildContext context) {
    final tips = [
      'Never click suspicious links in emails',
      'Verify sender identity before sharing personal information',
      'Keep your security software updated',
      'Use strong, unique passwords for each account',
      'Enable two-factor authentication when available',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.mcafeeDarkBlue),
                const SizedBox(width: 8),
                const Text(
                  'Security Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.safeGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}