message);
    securityProvider.analyzeMessage(message, sender: sender.isNotEmpty ? sender : null);
  }

  void _loadSampleMessage() {
    const sampleMessages = [
      {
        'message': 'Congratulations! You have won $1,000,000 in our lottery! Click here to claim your prize now! Act fast, this offer expires in 24 hours!',
        'sender': 'lottery-winner@suspicious-domain.com'
      },
      {
        'message': 'Urgent: Your account will be suspended. Please verify your identity immediately by clicking this link and entering your credentials.',
        'sender': 'security@paypaI.com'
      },
      {
        'message': 'Free Viagra! Limited time offer! Order now and save 90%! No prescription needed! Call 1-800-FAKE-NUM',
        'sender': 'deals@pharmacy-scam.biz'
      },
      {
        'message': 'FINAL NOTICE: Your payment is overdue. Legal action will be taken if you do not respond within 48 hours. Wire $500 immediately.',
        'sender': 'legal@fake-law-firm.net'
      },
      {
        'message': 'Hi John, just wanted to remind you about our meeting tomorrow at 3 PM in the conference room. Thanks!',
        'sender': 'colleague@company.com'
      },
    ];

    final random = (DateTime.now().millisecondsSinceEpoch % sampleMessages.length);
    final sample = sampleMessages[random];
    
    _messageController.text = sample['message']!;
    _senderController.text = sample['sender']!;
  }

  void _clearAnalysis() {
    Provider.of<SecurityProvider>(context, listen: false).clearCurrentAnalysis();
    _messageController.clear();
    _senderController.clear();
  }

  Widget _buildDetailedAnalysis(analysis) {
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
                  'Detailed Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Analysis Metrics
            _buildMetricRow('Spam Score', analysis.analysis['spamScore']),
            _buildMetricRow('Phishing Score', analysis.analysis['phishingScore']),
            _buildMetricRow('URL Risk Score', analysis.analysis['urlScore']),
            _buildMetricRow('Attachment Risk', analysis.analysis['attachmentScore']),
            _buildMetricRow('Social Engineering', analysis.analysis['socialEngineeringScore']),
            _buildMetricRow('Sender Risk', analysis.analysis['senderScore']),
            
            const Divider(height: 24),
            
            // Message Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Message Length', '${analysis.analysis['messageLength']} chars'),
                ),
                Expanded(
                  child: _buildStatItem('URLs Found', '${analysis.analysis['urlCount']}'),
                ),
                Expanded(
                  child: _buildStatItem('Attachments', '${analysis.analysis['attachmentCount']}'),
                ),
              ],
            ),
            
            // Suspicious Patterns
            if (analysis.analysis['suspiciousPatterns'] != null && 
                analysis.analysis['suspiciousPatterns'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Suspicious Patterns Detected:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.analysis['suspiciousPatterns'].map<Widget>(
                (pattern) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, size: 16, color: AppTheme.warningOrange),
                      const SizedBox(width: 8),
                      Text(pattern, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
            
            // Suspicious URLs
            if (analysis.suspiciousUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Suspicious URLs:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.suspiciousUrls.map<Widget>(
                (url) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_off, size: 16, color: AppTheme.dangerRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          url,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, double? value) {
    if (value == null) return const SizedBox.shrink();
    
    Color color = AppTheme.getThreatColor(value);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.mcafeeDarkBlue,
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

  Widget _buildSampleMessages(MessageProvider messageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: AppTheme.mcafeeDarkBlue),
                const SizedBox(width: 8),
                const Text(
                  'Test with Sample Messages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Try analyzing these sample messages to see how the security engine works:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSampleButton('Lottery Scam', AppTheme.dangerRed),
                _buildSampleButton('Phishing Alert', AppTheme.highThreat),
                _buildSampleButton('Spam Offer', AppTheme.warningOrange),
                _buildSampleButton('Threat Notice', AppTheme.criticalThreat),
                _buildSampleButton('Safe Message', AppTheme.safeGreen),
              ],
            ),
            
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  messageProvider.loadSampleMessages();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sample messages loaded in history'),
                      backgroundColor: AppTheme.safeGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Load All Samples'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mcafeeBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleButton(String label, Color color) {
    return ElevatedButton(
      onPressed: _loadSampleMessage,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}