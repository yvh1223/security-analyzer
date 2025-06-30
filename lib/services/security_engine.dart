        confidence: 0.8,
        evidence: domain,
      ));
    }

    return min(1.0, score);
  }

  /// Calculate overall threat score using weighted average
  static double _calculateOverallThreat(List<double> scores) {
    List<double> weights = [0.2, 0.25, 0.2, 0.15, 0.15, 0.05]; // Weighted importance
    
    double weightedSum = 0.0;
    for (int i = 0; i < scores.length; i++) {
      weightedSum += scores[i] * weights[i];
    }
    
    return min(1.0, weightedSum);
  }

  /// Determine threat level based on score
  static ThreatLevel _determineThreatLevel(double score) {
    if (score >= 0.9) return ThreatLevel.critical;
    if (score >= 0.7) return ThreatLevel.high;
    if (score >= 0.5) return ThreatLevel.medium;
    if (score >= 0.3) return ThreatLevel.low;
    return ThreatLevel.safe;
  }

  /// Extract URLs from text
  static List<String> _extractUrls(String text) {
    RegExp urlPattern = RegExp(
      r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
      caseSensitive: false,
    );
    
    return urlPattern.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// Extract suspicious URLs
  static List<String> _extractSuspiciousUrls(String text) {
    List<String> allUrls = _extractUrls(text);
    List<String> suspicious = [];
    
    for (String url in allUrls) {
      if (_suspiciousDomains.any((domain) => url.contains(domain)) ||
          _isShortUrl(url) ||
          _hasHomographAttack(url)) {
        suspicious.add(url);
      }
    }
    
    return suspicious;
  }

  /// Check if URL is shortened
  static bool _isShortUrl(String url) {
    List<String> shorteners = [
      'bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly',
      'short.ly', 'tiny.cc', 'is.gd', 'v.gd'
    ];
    
    return shorteners.any((shortener) => url.contains(shortener));
  }

  /// Check for homograph attacks (simplified)
  static bool _hasHomographAttack(String url) {
    // Check for common homograph characters
    List<String> homographs = ['аmаzоn', 'раyраl', 'gооglе', 'miсrоsоft'];
    return homographs.any((homograph) => url.toLowerCase().contains(homograph));
  }

  /// Find suspicious patterns in content
  static List<String> _findSuspiciousPatterns(String content) {
    List<String> patterns = [];
    
    // Check for suspicious patterns
    if (content.contains(RegExp(r'\$\d+(?:,\d{3})*(?:\.\d{2})?'))) {
      patterns.add('Contains monetary amounts');
    }
    
    if (content.contains(RegExp(r'\b\d{4}\s*\d{4}\s*\d{4}\s*\d{4}\b'))) {
      patterns.add('Contains credit card-like numbers');
    }
    
    if (content.contains(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'))) {
      patterns.add('Contains SSN-like patterns');
    }
    
    return patterns;
  }

  /// Generate security recommendations
  static List<String> generateRecommendations(SecurityAnalysisResult result) {
    List<String> recommendations = [];
    
    if (result.threatLevel == ThreatLevel.critical || result.threatLevel == ThreatLevel.high) {
      recommendations.add('🚨 DO NOT interact with this message');
      recommendations.add('🗑️ Delete this message immediately');
      recommendations.add('📢 Report to your security team');
    }
    
    if (result.suspiciousUrls.isNotEmpty) {
      recommendations.add('🔗 Do not click any links in this message');
      recommendations.add('🔍 Verify sender through alternative communication');
    }
    
    if (result.threats.any((t) => t.type == ThreatType.maliciousAttachment)) {
      recommendations.add('📎 Do not download or open attachments');
      recommendations.add('🛡️ Scan attachments with antivirus if already downloaded');
    }
    
    if (result.threats.any((t) => t.type == ThreatType.phishing)) {
      recommendations.add('🎣 This appears to be a phishing attempt');
      recommendations.add('🔐 Never enter credentials through email links');
    }
    
    if (result.threatLevel == ThreatLevel.medium) {
      recommendations.add('⚠️ Exercise caution with this message');
      recommendations.add('✅ Verify sender authenticity before responding');
    }
    
    if (result.threatLevel == ThreatLevel.safe) {
      recommendations.add('✅ Message appears safe');
      recommendations.add('👀 Always remain vigilant with email security');
    }
    
    return recommendations;
  }

  /// Get threat summary
  static String getThreatSummary(SecurityAnalysisResult result) {
    if (result.threatLevel == ThreatLevel.critical) {
      return 'Critical security threat detected. Do not interact with this message.';
    } else if (result.threatLevel == ThreatLevel.high) {
      return 'High security risk. Exercise extreme caution.';
    } else if (result.threatLevel == ThreatLevel.medium) {
      return 'Moderate security concerns detected. Verify sender authenticity.';
    } else if (result.threatLevel == ThreatLevel.low) {
      return 'Low security risk. Some suspicious elements found.';
    } else {
      return 'Message appears safe with no significant threats detected.';
    }
  }
}