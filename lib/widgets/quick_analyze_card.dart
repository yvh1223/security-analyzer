import 'package:flutter/material.dart';
import '../utils/theme.dart';

class QuickAnalyzeCard extends StatefulWidget {
  final Function(String message, String sender) onAnalyze;

  const QuickAnalyzeCard({
    super.key,
    required this.onAnalyze,
  });

  @override
  State<QuickAnalyzeCard> createState() => _QuickAnalyzeCardState();
}

class _QuickAnalyzeCardState extends State<QuickAnalyzeCard> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.mcafeeRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: AppTheme.mcafeeRed,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Security Check',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Paste a message to analyze for threats',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Paste your message here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppTheme.mcafeeRed,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          widget.onAnalyze(_controller.text.trim(), '');
                          _controller.clear();
                          setState(() {
                            _isExpanded = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.security),
                      label: const Text('Analyze Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mcafeeRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _loadSampleMessage();
                    },
                    icon: const Icon(Icons.quiz),
                    label: const Text('Sample'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.mcafeeRed,
                      side: const BorderSide(color: AppTheme.mcafeeRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  icon: const Icon(Icons.security),
                  label: const Text('Start Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mcafeeRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _loadSampleMessage() {
    const samples = [
      'Congratulations! You have won $1,000,000 in our lottery! Click here to claim now!',
      'Urgent: Your account will be suspended. Verify identity immediately.',
      'Free Viagra! Limited time offer! Order now and save 90%!',
      'FINAL NOTICE: Payment overdue. Legal action will be taken.',
      'Hi, reminder about our meeting tomorrow at 3 PM.',
    ];
    
    final sample = samples[DateTime.now().millisecondsSinceEpoch % samples.length];
    _controller.text = sample;
  }
}