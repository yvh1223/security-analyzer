import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SecurityMetricsCard extends StatelessWidget {
  final Map<String, int> statistics;

  const SecurityMetricsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final total = statistics['total'] ?? 0;
    
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
                  'Security Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No data available yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Total Messages Analyzed
              Center(
                child: Column(
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mcafeeDarkBlue,
                      ),
                    ),
                    Text(
                      'Messages Analyzed',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Threat Distribution
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem(
                    'Safe',
                    statistics['safe'] ?? 0,
                    AppTheme.safeGreen,
                    total,
                  ),
                  _buildMetricItem(
                    'Low Risk',
                    statistics['low'] ?? 0,
                    AppTheme.lowThreat,
                    total,
                  ),
                  _buildMetricItem(
                    'Medium',
                    statistics['medium'] ?? 0,
                    AppTheme.mediumThreat,
                    total,
                  ),
                  _buildMetricItem(
                    'High Risk',
                    statistics['high'] ?? 0,
                    AppTheme.highThreat,
                    total,
                  ),
                  _buildMetricItem(
                    'Critical',
                    statistics['critical'] ?? 0,
                    AppTheme.criticalThreat,
                    total,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Threat Detection Rate
              _buildThreatDetectionRate(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, int count, Color color, int total) {
    double percentage = total > 0 ? (count / total) * 100 : 0;
    
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildThreatDetectionRate() {
    final total = statistics['total'] ?? 0;
    final threats = (statistics['low'] ?? 0) + 
                   (statistics['medium'] ?? 0) + 
                   (statistics['high'] ?? 0) + 
                   (statistics['critical'] ?? 0);
    
    double detectionRate = total > 0 ? (threats / total) * 100 : 0;
    Color rateColor = detectionRate > 50 ? AppTheme.dangerRed : 
                     detectionRate > 25 ? AppTheme.warningOrange : 
                     AppTheme.safeGreen;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rateColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.radar,
            color: rateColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Threat Detection Rate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rateColor,
                  ),
                ),
                Text(
                  '${detectionRate.toStringAsFixed(1)}% of messages contained threats',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${detectionRate.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: rateColor,
            ),
          ),
        ],
      ),
    );
  }
}