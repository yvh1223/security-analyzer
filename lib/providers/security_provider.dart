import 'package:flutter/foundation.dart';
import '../models/security_models.dart';
import '../services/security_engine.dart';

class SecurityProvider extends ChangeNotifier {
  SecurityAnalysisResult? _currentAnalysis;
  bool _isAnalyzing = false;
  List<SecurityAnalysisResult> _analysisHistory = [];
  
  SecurityAnalysisResult? get currentAnalysis => _currentAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  List<SecurityAnalysisResult> get analysisHistory => _analysisHistory;

  /// Analyze a message for security threats
  Future<void> analyzeMessage(String content, {String? sender}) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      // Create message data object
      MessageData message = MessageData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        sender: sender ?? 'unknown@example.com',
        receivedAt: DateTime.now(),
      );

      // Perform security analysis
      _currentAnalysis = await SecurityAnalysisEngine.analyzeMessage(message);
      
      // Add to history
      _analysisHistory.insert(0, _currentAnalysis!);
      
      // Keep only last 100 analyses
      if (_analysisHistory.length > 100) {
        _analysisHistory = _analysisHistory.take(100).toList();
      }
      
    } catch (e) {
      debugPrint('Error analyzing message: $e');
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Clear current analysis
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
  }

  /// Clear analysis history
  void clearHistory() {
    _analysisHistory.clear();
    notifyListeners();
  }

  /// Get threat statistics
  Map<String, int> getThreatStatistics() {
    Map<String, int> stats = {
      'total': _analysisHistory.length,
      'safe': 0,
      'low': 0,
      'medium': 0,
      'high': 0,
      'critical': 0,
    };

    for (var analysis in _analysisHistory) {
      switch (analysis.threatLevel) {
        case ThreatLevel.safe:
          stats['safe'] = stats['safe']! + 1;
          break;
        case ThreatLevel.low:
          stats['low'] = stats['low']! + 1;
          break;
        case ThreatLevel.medium:
          stats['medium'] = stats['medium']! + 1;
          break;
        case ThreatLevel.high:
          stats['high'] = stats['high']! + 1;
          break;
        case ThreatLevel.critical:
          stats['critical'] = stats['critical']! + 1;
          break;
      }
    }

    return stats;
  }

  /// Get most common threat types
  Map<ThreatType, int> getThreatTypeStatistics() {
    Map<ThreatType, int> threatCounts = {};
    
    for (var analysis in _analysisHistory) {
      for (var threat in analysis.threats) {
        threatCounts[threat.type] = (threatCounts[threat.type] ?? 0) + 1;
      }
    }
    
    return threatCounts;
  }

  /// Get analysis by ID
  SecurityAnalysisResult? getAnalysisById(String id) {
    try {
      return _analysisHistory.firstWhere((analysis) => analysis.messageId == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete analysis from history
  void deleteAnalysis(String id) {
    _analysisHistory.removeWhere((analysis) => analysis.messageId == id);
    notifyListeners();
  }

  /// Get recommendations for current analysis
  List<String> getCurrentRecommendations() {
    if (_currentAnalysis == null) return [];
    return SecurityAnalysisEngine.generateRecommendations(_currentAnalysis!);
  }

  /// Get threat summary for current analysis
  String getCurrentThreatSummary() {
    if (_currentAnalysis == null) return 'No analysis available';
    return SecurityAnalysisEngine.getThreatSummary(_currentAnalysis!);
  }
}