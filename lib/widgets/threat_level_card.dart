import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/security_models.dart';

class ThreatLevelCard extends StatelessWidget {
  final SecurityAnalysisResult analysis;

  const ThreatLevelCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    Color threatColor = AppTheme.getThreatColor(analysis.threatScore);
    String threatDescription = AppTheme.getThreatDescription(analysis.threatScore);
    
    return Card(
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              threatColor.withOpacity(0.1),
              threatColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: threatColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getThreatIcon(analysis.threatLevel),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        threatDescription,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: threatColor,
                        ),
                      ),
                      Text(
                        'Threat Score: ${(analysis.threatScore * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Threat Score Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade300,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: analysis.threatScore,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: threatColor,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Threats',
                  analysis.threats.length.toString(),
                  Icons.warning,
                ),
                _buildStatItem(
                  'URLs',
                  analysis.suspiciousUrls.length.toString(),
                  Icons.link,
                ),
                _buildStatItem(
                  'Analysis Time',
                  '${DateTime.now().difference(analysis.analyzedAt).inSeconds}s ago',
                  Icons.schedule,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
}