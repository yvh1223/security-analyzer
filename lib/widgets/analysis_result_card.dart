import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/security_models.dart';

class AnalysisResultCard extends StatelessWidget {
  final SecurityAnalysisResult analysis;
  final List<String> recommendations;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    Color threatColor = AppTheme.getThreatColor(analysis.threatScore);
    String threatDescription = AppTheme.getThreatDescription(analysis.threatScore);
    
    return Card(
      elevation: 6,
      child: Column(
        children: [
          // Header with threat level
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: threatColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getThreatIcon(analysis.threatLevel),
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        threatDescription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Security Score: ${(analysis.threatScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    analysis.threatLevel.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                Text(
                  _getThreatSummary(analysis),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                if (analysis.threats.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Threats Detected:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.threats.take(3).map(
                    (threat) => _buildThreatItem(threat),
                  ),
                  if (analysis.threats.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${analysis.threats.length - 3} more threats detected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
                
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Recommendations:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendations.take(3).map(
                    (rec) => _buildRecommendationItem(rec),
                  ),
                ],
                
                // Analysis timestamp
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Analyzed ${_formatTime(analysis.analyzedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatItem(ThreatIndicator threat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warningOrange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getThreatTypeIcon(threat.type),
            color: AppTheme.warningOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  threat.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (threat.evidence != null)
                  Text(
                    threat.evidence!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(threat.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.warningOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.safeGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getThreatIcon(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
        return Icons.dangerous;
      case ThreatLevel.high:
        return Icons.warning;
      case ThreatLevel.medium:
        return Icons.info;
      case ThreatLevel.low:
        return Icons.info_outline;
      case ThreatLevel.safe:
        return Icons.check_circle;
    }
  }

  IconData _getThreatTypeIcon(ThreatType type) {
    switch (type) {
      case ThreatType.spam:
        return Icons.spam;
      case ThreatType.phishing:
        return Icons.phishing;
      case ThreatType.malware:
        return Icons.bug_report;
      case ThreatType.suspiciousUrl:
        return Icons.link_off;
      case ThreatType.maliciousAttachment:
        return Icons.attachment;
      case ThreatType.socialEngineering:
        return Icons.psychology;
      default:
        return Icons.warning;
    }
  }

  String _getThreatSummary(SecurityAnalysisResult analysis) {
    if (analysis.threatLevel == ThreatLevel.critical) {
      return 'Critical security threat detected. Do not interact with this message under any circumstances.';
    } else if (analysis.threatLevel == ThreatLevel.high) {
      return 'High security risk detected. Exercise extreme caution and verify sender authenticity.';
    } else if (analysis.threatLevel == ThreatLevel.medium) {
      return 'Moderate security concerns found. Verify the sender before taking any action.';
    } else if (analysis.threatLevel == ThreatLevel.low) {
      return 'Low security risk with some suspicious elements. Proceed with normal caution.';
    } else {
      return 'Message appears safe with no significant security threats detected.';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }
}