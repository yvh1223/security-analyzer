import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/security_models.dart';

class AnalysisHistoryItem extends StatelessWidget {
  final SecurityAnalysisResult analysis;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AnalysisHistoryItem({
    super.key,
    required this.analysis,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color threatColor = AppTheme.getThreatColor(analysis.threatScore);
    String threatDescription = AppTheme.getThreatDescription(analysis.threatScore);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: threatColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: threatColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      threatDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: threatColor,
                      ),
                    ),
                  ),
                  Text(
                    '${(analysis.threatScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: threatColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: const Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppTheme.dangerRed),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppTheme.dangerRed)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'view') {
                        onTap();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Message preview
              Text(
                analysis.messageContent.length > 120
                    ? '${analysis.messageContent.substring(0, 120)}...'
                    : analysis.messageContent,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Threat summary
              if (analysis.threats.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: analysis.threats.take(3).map((threat) => 
                    _buildThreatBadge(threat.type)
                  ).toList(),
                ),
                const SizedBox(height: 8),
              ],
              
              // Footer row
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(analysis.analyzedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (analysis.suspiciousUrls.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.link_off,
                          size: 14,
                          color: AppTheme.warningOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${analysis.suspiciousUrls.length} suspicious URL${analysis.suspiciousUrls.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.warningOrange,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatBadge(ThreatType type) {
    Color badgeColor = _getThreatTypeColor(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}