import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:validators/validators.dart';
import 'dart:convert';
import '../models/security_models.dart';

class SecurityAnalysisEngine {
  // Malicious patterns database (simplified for demo)
  static const List<String> _spamKeywords = [
    'congratulations', 'winner', 'free money', 'urgent', 'act now',
    'limited time', 'click here', 'call now', 'guarantee', 'no risk',
    'make money fast', 'work from home', 'lose weight', 'viagra',
    'lottery', 'inheritance', 'nigerian prince', 'wire transfer'
  ];

  static const List<String> _phishingPatterns = [
    'verify your account', 'update payment', 'suspend account',
    'click to verify', 'confirm identity', 'security alert',
    'unusual activity', 'login attempt', 'expires today'
  ];

  static const List<String> _maliciousFileExtensions = [
    '.exe', '.scr', '.bat', '.cmd', '.com', '.pif', '.vbs', '.js'
  ];

  static const List<String> _suspiciousDomains = [
    'bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly',
    'paypaI.com', 'arnazon.com', 'microsft.com', 'gmai1.com'
  ];

  static const List<String> _urgencyIndicators = [
    'urgent', 'immediate', 'expires', 'deadline', 'act now',
    'limited time', 'hurry', 'last chance', 'final notice'
  ];

  /// Main analysis function
  static Future<SecurityAnalysisResult> analyzeMessage(MessageData message) async {
    List<ThreatIndicator> threats = [];
    Map<String, dynamic> analysis = {};
    
    // Perform various security checks
    double spamScore = _analyzeSpamIndicators(message.content, threats);
    double phishingScore = _analyzePhishingIndicators(message.content, threats);
    double urlScore = await _analyzeUrls(message.content, threats);
    double attachmentScore = _analyzeAttachments(message.attachments, threats);
    double socialEngScore = _analyzeSocialEngineering(message.content, threats);
    double senderScore = _analyzeSender(message.sender, threats);
    
    // Calculate overall threat score
    double overallThreatScore = _calculateOverallThreat([
      spamScore,
      phishingScore,
      urlScore,
      attachmentScore,
      socialEngScore,
      senderScore,
    ]);

    // Determine threat level
    ThreatLevel threatLevel = _determineThreatLevel(overallThreatScore);

    // Compile analysis details
    analysis = {
      'spamScore': spamScore,
      'phishingScore': phishingScore,
      'urlScore': urlScore,
      'attachmentScore': attachmentScore,
      'socialEngineeringScore': socialEngScore,
      'senderScore': senderScore,
      'messageLength': message.content.length,
      'urlCount': _extractUrls(message.content).length,
      'attachmentCount': message.attachments.length,
      'suspiciousPatterns': _findSuspiciousPatterns(message.content),
    };

    List<String> suspiciousUrls = _extractSuspiciousUrls(message.content);

    return SecurityAnalysisResult(
      messageId: message.id,
      messageContent: message.content,
      threatScore: overallThreatScore,
      threatLevel: threatLevel,
      threats: threats,
      suspiciousUrls: suspiciousUrls,
      analysis: analysis,
      analyzedAt: DateTime.now(),
    );
  }

  /// Analyze spam indicators
  static double _analyzeSpamIndicators(String content, List<ThreatIndicator> threats) {
    double score = 0.0;
    String lowerContent = content.toLowerCase();
    
    int spamWordCount = 0;
    for (String keyword in _spamKeywords) {
      if (lowerContent.contains(keyword.toLowerCase())) {
        spamWordCount++;
      }
    }
    
    if (spamWordCount > 0) {
      score = min(1.0, spamWordCount * 0.2);
      threats.add(ThreatIndicator(
        type: ThreatType.spam,
        description: 'Contains $spamWordCount spam-related keywords',
        confidence: score,
        evidence: 'Spam keywords detected',
      ));
    }

    // Check for excessive capitalization
    int capitalLetters = content.replaceAll(RegExp(r'[^A-Z]'), '').length;
    double capRatio = capitalLetters / content.length;
    if (capRatio > 0.3) {
      score += 0.3;
      threats.add(ThreatIndicator(
        type: ThreatType.spam,
        description: 'Excessive use of capital letters',
        confidence: 0.6,
        evidence: '${(capRatio * 100).toStringAsFixed(1)}% capital letters',
      ));
    }

    return min(1.0, score);
  }

  /// Analyze phishing indicators
  static double _analyzePhishingIndicators(String content, List<ThreatIndicator> threats) {
    double score = 0.0;
    String lowerContent = content.toLowerCase();
    
    int phishingPatternCount = 0;
    for (String pattern in _phishingPatterns) {
      if (lowerContent.contains(pattern.toLowerCase())) {
        phishingPatternCount++;
      }
    }
    
    if (phishingPatternCount > 0) {
      score = min(1.0, phishingPatternCount * 0.3);
      threats.add(ThreatIndicator(
        type: ThreatType.phishing,
        description: 'Contains $phishingPatternCount phishing-related patterns',
        confidence: score,
        evidence: 'Phishing patterns detected',
      ));
    }

    // Check for urgency indicators
    int urgencyCount = 0;
    for (String indicator in _urgencyIndicators) {
      if (lowerContent.contains(indicator.toLowerCase())) {
        urgencyCount++;
      }
    }
    
    if (urgencyCount > 0) {
      score += min(0.4, urgencyCount * 0.15);
      threats.add(ThreatIndicator(
        type: ThreatType.phishing,
        description: 'Uses urgency tactics to pressure action',
        confidence: 0.7,
        evidence: '$urgencyCount urgency indicators found',
      ));
    }

    return min(1.0, score);
  }

  /// Analyze URLs in the message
  static Future<double> _analyzeUrls(String content, List<ThreatIndicator> threats) async {
    List<String> urls = _extractUrls(content);
    if (urls.isEmpty) return 0.0;

    double score = 0.0;
    int suspiciousUrlCount = 0;

    for (String url in urls) {
      // Check for suspicious domains
      bool isSuspicious = _suspiciousDomains.any((domain) => url.contains(domain));
      
      // Check for URL shorteners
      bool isShortened = _isShortUrl(url);
      
      // Check for homograph attacks
      bool hasHomograph = _hasHomographAttack(url);
      
      if (isSuspicious || isShortened || hasHomograph) {
        suspiciousUrlCount++;
        
        threats.add(ThreatIndicator(
          type: ThreatType.suspiciousUrl,
          description: 'Suspicious URL detected: $url',
          confidence: 0.8,
          evidence: url,
        ));
      }
    }

    if (suspiciousUrlCount > 0) {
      score = min(1.0, suspiciousUrlCount * 0.4);
    }

    // Penalize messages with too many URLs
    if (urls.length > 3) {
      score += 0.3;
      threats.add(ThreatIndicator(
        type: ThreatType.spam,
        description: 'Excessive number of URLs (${urls.length})',
        confidence: 0.6,
        evidence: '${urls.length} URLs found',
      ));
    }

    return min(1.0, score);
  }

  /// Analyze attachments
  static double _analyzeAttachments(List<String> attachments, List<ThreatIndicator> threats) {
    if (attachments.isEmpty) return 0.0;

    double score = 0.0;
    
    for (String attachment in attachments) {
      String extension = attachment.toLowerCase().substring(attachment.lastIndexOf('.'));
      
      if (_maliciousFileExtensions.contains(extension)) {
        score += 0.8;
        threats.add(ThreatIndicator(
          type: ThreatType.maliciousAttachment,
          description: 'Potentially malicious file type: $extension',
          confidence: 0.9,
          evidence: attachment,
        ));
      }
    }

    return min(1.0, score);
  }

  /// Analyze social engineering tactics
  static double _analyzeSocialEngineering(String content, List<ThreatIndicator> threats) {
    double score = 0.0;
    String lowerContent = content.toLowerCase();

    // Check for emotional manipulation
    List<String> emotionalTriggers = [
      'congratulations', 'winner', 'emergency', 'help', 'urgent',
      'final notice', 'suspended', 'expires', 'act now'
    ];

    int emotionalCount = 0;
    for (String trigger in emotionalTriggers) {
      if (lowerContent.contains(trigger)) {
        emotionalCount++;
      }
    }

    if (emotionalCount > 2) {
      score += 0.5;
      threats.add(ThreatIndicator(
        type: ThreatType.socialEngineering,
        description: 'Uses emotional manipulation tactics',
        confidence: 0.7,
        evidence: '$emotionalCount emotional triggers found',
      ));
    }

    // Check for authority impersonation
    List<String> authorityKeywords = [
      'bank', 'paypal', 'amazon', 'microsoft', 'apple', 'google',
      'irs', 'government', 'police', 'security team'
    ];

    for (String keyword in authorityKeywords) {
      if (lowerContent.contains(keyword)) {
        score += 0.3;
        threats.add(ThreatIndicator(
          type: ThreatType.socialEngineering,
          description: 'May be impersonating trusted authority',
          confidence: 0.6,
          evidence: 'References: $keyword',
        ));
        break;
      }
    }

    return min(1.0, score);
  }

  /// Analyze sender reputation
  static double _analyzeSender(String sender, List<ThreatIndicator> threats) {
    double score = 0.0;

    // Check for suspicious sender patterns
    if (!isEmail(sender)) {
      score += 0.4;
      threats.add(ThreatIndicator(
        type: ThreatType.spam,
        description: 'Invalid email format',
        confidence: 0.8,
        evidence: sender,
      ));
    }

    // Check for suspicious domains in sender
    String domain = sender.split('@').length > 1 ? sender.split('@')[1] : '';
    if (_suspiciousDomains.any((suspDomain) => domain.contains(suspDomain))) {
      score += 0.6;
      threats.add(ThreatIndicator(
        type: ThreatType.phishing,
        description: 'Sender from suspicious domain',
        confidence: 0.8,
        evidence: domain,
      ));
    }

    return min(1.0, score);
  }

  /// Helper methods
  static List<String> _extractUrls(String content) {
    RegExp urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    return urlRegex.allMatches(content).map((match) => match.group(0)!).toList();
  }

  static List<String> _extractSuspiciousUrls(String content) {
    List<String> urls = _extractUrls(content);
    return urls.where((url) => 
      _suspiciousDomains.any((domain) => url.contains(domain)) ||
      _isShortUrl(url) ||
      _hasHomographAttack(url)
    ).toList();
  }

  static bool _isShortUrl(String url) {
    List<String> shortDomains = ['bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly'];
    return shortDomains.any((domain) => url.contains(domain));
  }

  static bool _hasHomographAttack(String url) {
    // Simplified homograph detection
    List<String> homographs = ['paypaI', 'arnazon', 'microsft', 'gmai1'];
    return homographs.any((homograph) => url.toLowerCase().contains(homograph));
  }

  static List<String> _findSuspiciousPatterns(String content) {
    List<String> patterns = [];
    String lowerContent = content.toLowerCase();

    // Financial requests
    if (lowerContent.contains('wire transfer') || 
        lowerContent.contains('send money') ||
        lowerContent.contains('bank details')) {
      patterns.add('Financial request detected');
    }

    // Personal information requests
    if (lowerContent.contains('ssn') || 
        lowerContent.contains('social security') ||
        lowerContent.contains('credit card')) {
      patterns.add('Personal information request');
    }

    // Fake lottery/prize
    if (lowerContent.contains('lottery') || 
        lowerContent.contains('jackpot') ||
        lowerContent.contains('prize')) {
      patterns.add('Fake lottery/prize scheme');
    }

    return patterns;
  }

  static double _calculateOverallThreat(List<double> scores) {
    if (scores.isEmpty) return 0.0;
    
    // Weighted average with emphasis on highest scores
    scores.sort((a, b) => b.compareTo(a));
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    for (int i = 0; i < scores.length; i++) {
      double weight = 1.0 / (i + 1); // Higher weight for higher scores
      weightedSum += scores[i] * weight;
      totalWeight += weight;
    }
    
    return weightedSum / totalWeight;
  }

  static ThreatLevel _determineThreatLevel(double score) {
    if (score >= 0.9) return ThreatLevel.critical;
    if (score >= 0.7) return ThreatLevel.high;
    if (score >= 0.5) return ThreatLevel.medium;
    if (score >= 0.3) return ThreatLevel.low;
    return ThreatLevel.safe;
  }

  /// Generate detailed security report
  static Map<String, dynamic> generateSecurityReport(SecurityAnalysisResult result) {
    return {
      'summary': {
        'threatLevel': result.threatLevel.name.toUpperCase(),
        'threatScore': '${(result.threatScore * 100).toStringAsFixed(1)}%',
        'totalThreats': result.threats.length,
        'recommendation': _getRecommendation(result.threatLevel),
      },
      'threats': result.threats.map((threat) => {
        'type': threat.type.name,
        'description': threat.description,
        'confidence': '${(threat.confidence * 100).toStringAsFixed(1)}%',
        'evidence': threat.evidence,
      }).toList(),
      'analysis': result.analysis,
      'suspiciousUrls': result.suspiciousUrls,
      'timestamp': result.analyzedAt.toIso8601String(),
    };
  }

  static String _getRecommendation(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
        return 'BLOCK IMMEDIATELY - High risk of malicious content';
      case ThreatLevel.high:
        return 'QUARANTINE - Manual review required before delivery';
      case ThreatLevel.medium:
        return 'FLAG - Warn user about potential risks';
      case ThreatLevel.low:
        return 'CAUTION - Monitor but allow with warnings';
      case ThreatLevel.safe:
        return 'ALLOW - Message appears safe';
    }
  }
}