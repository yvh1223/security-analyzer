import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../utils/theme.dart';
import '../widgets/analysis_history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Critical', 'High', 'Medium', 'Low', 'Safe'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        backgroundColor: AppTheme.mcafeeDarkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, securityProvider, child) {
          final allAnalyses = securityProvider.analysisHistory;
          final filteredAnalyses = _filterAnalyses(allAnalyses);
          
          return Column(
            children: [
              // Statistics Header
              _buildStatisticsHeader(securityProvider),
              
              // Filter Chips
              _buildFilterChips(),
              
              // Analysis List
              Expanded(
                child: filteredAnalyses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAnalyses.length,
                        itemBuilder: (context, index) {
                          final analysis = filteredAnalyses[index];
                          return AnalysisHistoryItem(
                            analysis: analysis,
                            onDelete: () => _deleteAnalysis(securityProvider, analysis.messageId),
                            onTap: () => _showAnalysisDetails(analysis),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsHeader(SecurityProvider securityProvider) {
    final stats = securityProvider.getThreatStatistics();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.mcafeeDarkBlue, AppTheme.mcafeeBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', stats['total']!, Colors.white),
          _buildStatItem('Safe', stats['safe']!, AppTheme.safeGreen),
          _buildStatItem('Threats', 
              stats['low']! + stats['medium']! + stats['high']! + stats['critical']!, 
              AppTheme.dangerRed),
          _buildStatItem('Critical', stats['critical']!, AppTheme.criticalThreat),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppTheme.mcafeeRed.withOpacity(0.2),
              checkmarkColor: AppTheme.mcafeeRed,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    if (_selectedFilter == 'All') {
      message = 'No messages analyzed yet.\nStart by analyzing a message in the Analysis tab.';
      icon = Icons.inbox;
    } else {
      message = 'No ${_selectedFilter.toLowerCase()} threat messages found.';
      icon = Icons.filter_list_off;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterAnalyses(List<dynamic> analyses) {
    if (_selectedFilter == 'All') return analyses;
    
    return analyses.where((analysis) {
      switch (_selectedFilter) {
        case 'Critical':
          return analysis.threatLevel.name == 'critical';
        case 'High':
          return analysis.threatLevel.name == 'high';
        case 'Medium':
          return analysis.threatLevel.name == 'medium';
        case 'Low':
          return analysis.threatLevel.name == 'low';
        case 'Safe':
          return analysis.threatLevel.name == 'safe';
        default:
          return true;
      }
    }).toList();
  }

  void _deleteAnalysis(SecurityProvider securityProvider, String id) {
    securityProvider.deleteAnalysis(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analysis deleted'),
        backgroundColor: AppTheme.safeGreen,
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text('Are you sure you want to clear all analysis history? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<SecurityProvider>(context, listen: false).clearHistory();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared'),
                    backgroundColor: AppTheme.safeGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showAnalysisDetails(dynamic analysis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getThreatColor(analysis.threatScore),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Analysis Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Threat Level
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getThreatColor(analysis.threatScore).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.getThreatColor(analysis.threatScore),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: AppTheme.getThreatColor(analysis.threatScore),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${AppTheme.getThreatDescription(analysis.threatScore)} (${(analysis.threatScore * 100).toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getThreatColor(analysis.threatScore),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Message Content
                        const Text(
                          'Message Content:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(analysis.messageContent),
                        ),
                        const SizedBox(height: 16),
                        
                        // Threats Found
                        if (analysis.threats.isNotEmpty) ...[
                          const Text(
                            'Threats Detected:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...analysis.threats.map<Widget>((threat) => 
                            _buildThreatItem(threat),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Analysis Time
                        Text(
                          'Analyzed: ${_formatDateTime(analysis.analyzedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
      },
    );
  }

  Widget _buildThreatItem(dynamic threat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getThreatIcon(threat.type),
                size: 16,
                color: AppTheme.warningOrange,
              ),
              const SizedBox(width: 8),
              Text(
                threat.type.toString().split('.').last.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningOrange,
                ),
              ),
              const Spacer(),
              Text(
                '${(threat.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            threat.description,
            style: const TextStyle(fontSize: 14),
          ),
          if (threat.evidence != null) ...[
            const SizedBox(height: 4),
            Text(
              'Evidence: ${threat.evidence}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getThreatIcon(dynamic threatType) {
    switch (threatType.toString().split('.').last) {
      case 'spam':
        return Icons.spam;
      case 'phishing':
        return Icons.phishing;
      case 'malware':
        return Icons.bug_report;
      case 'suspiciousUrl':
        return Icons.link_off;
      case 'maliciousAttachment':
        return Icons.attachment;
      case 'socialEngineering':
        return Icons.psychology;
      default:
        return Icons.warning;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}