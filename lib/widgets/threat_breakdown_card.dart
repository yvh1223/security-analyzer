import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/security_models.dart';

class ThreatBreakdownCard extends StatelessWidget {
  final SecurityAnalysisResult analysis;

  const ThreatBreakdownCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppTheme.mcafeeDarkBlue),
                const SizedBox(width: 8),
                const Text(
                  'Threat Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Analysis scores
            _buildScoreBar('Spam Detection', analysis.analysis['spamScore']),
            _buildScoreBar('Phishing Detection', analysis.analysis['phishingScore']),
            _buildScoreBar('URL Analysis', analysis.analysis['urlScore']),
            _buildScoreBar('Attachment Scan', analysis.analysis['attachmentScore']),
            _buildScoreBar('Social Engineering', analysis.analysis['socialEngineeringScore']),
            _buildScoreBar('Sender Reputation', analysis.analysis['senderScore']),
            
            const SizedBox(height: 16),
            
            // Overall score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getThreatColor(analysis.threatScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getThreatColor(analysis.threatScore).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppTheme.getThreatColor(analysis.threatScore),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Threat Score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getThreatColor(analysis.threatScore),
                          ),
                        ),
                        Text(
                          AppTheme.getThreatDescription(analysis.threatScore),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(analysis.threatScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getThreatColor(analysis.threatScore),
                    ),
                  ),
                ],
              ),
            ),
            
            if (analysis.threats.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Threat Types Detected:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.threats.map((threat) => _buildThreatChip(threat)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, dynamic scoreValue) {
    double score = scoreValue?.toDouble() ?? 0.0;
    Color color = AppTheme.getThreatColor(score);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(score * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildThreatChip(ThreatIndicator threat) {
    Color chipColor = _getThreatTypeColor(threat.type);
    
    return Chip(
      avatar: Icon(
        _getThreatTypeIcon(threat.type),
        size: 16,
        color: chipColor,
      ),
      label: Text(
        threat.type.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
    );
  }

  Color _getThreatTypeColor(ThreatType type) {
    switch (type) {
      case ThreatType.spam:
        return AppTheme.warningOrange;
      case ThreatType.phishing:
        return AppTheme.dangerRed;
      case ThreatType.malware:
        return AppTheme.criticalThreat;
      case ThreatType.suspiciousUrl:
        return AppTheme.highThreat;
      case ThreatType.maliciousAttachment:
        return AppTheme.criticalThreat;
      case ThreatType.socialEngineering:
        return AppTheme.mediumThreat;
      default:
        return AppTheme.lowThreat;
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
}