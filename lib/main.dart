import 'package:flutter/material.dart';

void main() {
  runApp(const McAfeeSecurityAnalyzer());
}

class McAfeeSecurityAnalyzer extends StatelessWidget {
  const McAfeeSecurityAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'McAfee Security Analyzer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE31E24), // McAfee Red
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366), // McAfee Dark Blue
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  String _analysisResult = '';
  bool _isAnalyzing = false;

  final List<Map<String, dynamic>> _analysisHistory = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('McAfee Security Analyzer'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildAnalysisTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE31E24),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Security',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003366), Color(0xFF0078D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Analysis Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: Color(0xFFE31E24)),
                      SizedBox(width: 8),
                      Text(
                        'Quick Security Check',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Paste your message here to analyze for threats...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeMessage,
                          icon: _isAnalyzing 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.security),
                          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE31E24),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _loadSampleMessage,
                        icon: const Icon(Icons.quiz),
                        label: const Text('Load Sample'),
                      ),
                    ],
                  ),
                  if (_analysisResult.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(_analysisResult),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Color(0xFF003366)),
                      SizedBox(width: 8),
                      Text(
                        'Security Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total Scanned', _analysisHistory.length.toString(), Colors.blue),
                      _buildStatItem('Threats Found', _analysisHistory.where((a) => a['threatLevel'] == 'high').length.toString(), Colors.red),
                      _buildStatItem('Safe Messages', _analysisHistory.where((a) => a['threatLevel'] == 'safe').length.toString(), Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Message to Analyze:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Paste email or message content here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeMessage,
                          icon: _isAnalyzing 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.security),
                          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE31E24),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _loadSampleMessage,
                        icon: const Icon(Icons.quiz),
                        label: const Text('Sample'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (_analysisResult.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Results:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(_analysisResult, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analysis History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: _analysisHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No messages analyzed yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _analysisHistory.length,
                  itemBuilder: (context, index) {
                    final analysis = _analysisHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          analysis['threatLevel'] == 'high' ? Icons.dangerous : 
                          analysis['threatLevel'] == 'medium' ? Icons.warning : Icons.check_circle,
                          color: analysis['threatLevel'] == 'high' ? Colors.red : 
                                 analysis['threatLevel'] == 'medium' ? Colors.orange : Colors.green,
                        ),
                        title: Text(
                          analysis['message'].length > 50 
                            ? '${analysis['message'].substring(0, 50)}...'
                            : analysis['message'],
                        ),
                        subtitle: Text('Threat Level: ${analysis['threatLevel']}'),
                        trailing: Text(analysis['timestamp']),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Real-time Scanning'),
                    subtitle: Text('Enable continuous message monitoring'),
                    trailing: Switch(value: true, onChanged: null),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Threat Notifications'),
                    subtitle: Text('Get alerts when threats are detected'),
                    trailing: Switch(value: true, onChanged: null),
                  ),
                  ListTile(
                    leading: Icon(Icons.analytics),
                    title: Text('Advanced Analysis'),
                    subtitle: Text('Use ML-powered threat detection'),
                    trailing: Switch(value: true, onChanged: null),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About McAfee Security Analyzer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('Version: 1.0.0'),
                  Text('Security Engine: Advanced Threat Detection'),
                  Text('Built with Flutter for cross-platform security'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message to analyze')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple threat analysis simulation
    String message = _messageController.text.toLowerCase();
    String threatLevel = 'safe';
    String result = '';
    
    List<String> spamKeywords = ['congratulations', 'winner', 'free money', 'urgent', 'click here', 'lottery', 'viagra'];
    List<String> phishingKeywords = ['verify account', 'suspend', 'update payment', 'security alert'];
    
    int spamCount = spamKeywords.where((keyword) => message.contains(keyword)).length;
    int phishingCount = phishingKeywords.where((keyword) => message.contains(keyword)).length;
    
    if (spamCount > 2 || phishingCount > 1) {
      threatLevel = 'high';
      result = '🚨 HIGH THREAT DETECTED\n\n';
      result += 'This message contains multiple indicators of spam/phishing:\n';
      if (spamCount > 0) result += '• $spamCount spam indicators found\n';
      if (phishingCount > 0) result += '• $phishingCount phishing patterns detected\n';
      result += '\nRECOMMENDATION: Do not interact with this message. Delete immediately.';
    } else if (spamCount > 0 || phishingCount > 0) {
      threatLevel = 'medium';
      result = '⚠️ MODERATE THREAT DETECTED\n\n';
      result += 'Suspicious patterns found:\n';
      if (spamCount > 0) result += '• Potential spam content detected\n';
      if (phishingCount > 0) result += '• Possible phishing attempt\n';
      result += '\nRECOMMENDATION: Exercise caution. Verify sender authenticity.';
    } else {
      threatLevel = 'safe';
      result = '✅ MESSAGE APPEARS SAFE\n\n';
      result += 'No significant threats detected in this message.\n\n';
      result += 'RECOMMENDATION: Message appears legitimate, but always remain vigilant.';
    }

    // Add to history
    _analysisHistory.insert(0, {
      'message': _messageController.text,
      'threatLevel': threatLevel,
      'timestamp': DateTime.now().toString().substring(0, 16),
      'result': result,
    });

    setState(() {
      _isAnalyzing = false;
      _analysisResult = result;
    });

    // Clear the message after analysis
    _messageController.clear();
  }

  void _loadSampleMessage() {
    const samples = [
      'Congratulations! You have won \$1,000,000 in our lottery! Click here to claim your prize now!',
      'Urgent: Your account will be suspended. Please verify your identity immediately.',
      'Free Viagra! Limited time offer! Order now and save 90%!',
      'Hi John, just wanted to remind you about our meeting tomorrow at 3 PM.',
      'FINAL NOTICE: Your payment is overdue. Legal action will be taken.',
    ];
    
    final sample = samples[DateTime.now().millisecondsSinceEpoch % samples.length];
    _messageController.text = sample;
  }
}