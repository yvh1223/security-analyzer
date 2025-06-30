 12)),
          ],
        ),
        Text(
          'Current: ${_getSensitivityLabel(_sensitivityLevel)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.dangerRed : AppTheme.mcafeeDarkBlue),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.dangerRed : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getSensitivityLabel(double value) {
    if (value <= 0.2) return 'Very Low';
    if (value <= 0.4) return 'Low';
    if (value <= 0.6) return 'Medium';
    if (value <= 0.8) return 'High';
    return 'Very High';
  }

  void _showSenderManagement(BuildContext context, MessageProvider messageProvider, bool isTrusted) {
    final senders = isTrusted ? messageProvider.trustedSenders : messageProvider.blockedSenders;
    final title = isTrusted ? 'Trusted Senders' : 'Blocked Senders';
    final color = isTrusted ? AppTheme.safeGreen : AppTheme.dangerRed;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTrusted ? Icons.verified_user : Icons.block,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
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
                
                Expanded(
                  child: senders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isTrusted ? Icons.verified_user : Icons.block,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ${isTrusted ? 'trusted' : 'blocked'} senders yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: senders.length,
                          itemBuilder: (context, index) {
                            final sender = senders[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  isTrusted ? Icons.verified_user : Icons.block,
                                  color: color,
                                ),
                                title: Text(sender),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    if (isTrusted) {
                                      messageProvider.untrustSender(sender);
                                    } else {
                                      messageProvider.unblockSender(sender);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddSenderDialog(context, messageProvider, isTrusted),
                    icon: const Icon(Icons.add),
                    label: Text('Add ${isTrusted ? 'Trusted' : 'Blocked'} Sender'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
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

  void _showAddSenderDialog(BuildContext context, MessageProvider messageProvider, bool isTrusted) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add ${isTrusted ? 'Trusted' : 'Blocked'} Sender'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'example@domain.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = controller.text.trim();
                if (email.isNotEmpty) {
                  if (isTrusted) {
                    messageProvider.trustSender(email);
                  } else {
                    messageProvider.blockSender(email);
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close the management dialog too
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _exportData() {
    // In a real app, this would export data to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality would be implemented here'),
        backgroundColor: AppTheme.mcafeeBlue,
      ),
    );
  }

  void _showClearDataDialog(MessageProvider messageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all analysis history, trusted/blocked senders, and reset all settings. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear all data
                messageProvider.clearRecentMessages();
                messageProvider.clearBlockedSenders();
                messageProvider.clearTrustedSenders();
                Provider.of<SecurityProvider>(context, listen: false).clearHistory();
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
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

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.mcafeeDarkBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.privacy_tip, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
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
                
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '''
McAfee Security Analyzer Privacy Policy

Data Collection:
• We analyze message content locally on your device
• No message content is sent to external servers
• Analysis history is stored locally only

Data Usage:
• Message analysis is performed for security purposes only
• Threat detection patterns are used to improve security
• No personal data is shared with third parties

Data Storage:
• All data is stored locally on your device
• You can clear all data at any time in Settings
• Uninstalling the app removes all stored data

Security:
• All analysis is performed using local algorithms
• No internet connection required for core functionality
• Your privacy and security are our top priorities

Contact:
For questions about this privacy policy, please contact our security team.
                      ''',
                      style: TextStyle(fontSize: 14, height: 1.5),
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
}