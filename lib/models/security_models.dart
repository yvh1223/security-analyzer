class SecurityAnalysisResult {
  final String messageId;
  final String messageContent;
  final double threatScore; // 0.0 to 1.0
  final ThreatLevel threatLevel;
  final List<ThreatIndicator> threats;
  final List<String> suspiciousUrls;
  final Map<String, dynamic> analysis;
  final DateTime analyzedAt;

  SecurityAnalysisResult({
    required this.messageId,
    required this.messageContent,
    required this.threatScore,
    required this.threatLevel,
    required this.threats,
    required this.suspiciousUrls,
    required this.analysis,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'messageContent': messageContent,
      'threatScore': threatScore,
      'threatLevel': threatLevel.name,
      'threats': threats.map((t) => t.toJson()).toList(),
      'suspiciousUrls': suspiciousUrls,
      'analysis': analysis,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory SecurityAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SecurityAnalysisResult(
      messageId: json['messageId'],
      messageContent: json['messageContent'],
      threatScore: json['threatScore'].toDouble(),
      threatLevel: ThreatLevel.values.firstWhere(
        (e) => e.name == json['threatLevel'],
      ),
      threats: (json['threats'] as List)
          .map((t) => ThreatIndicator.fromJson(t))
          .toList(),
      suspiciousUrls: List<String>.from(json['suspiciousUrls']),
      analysis: json['analysis'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }
}

enum ThreatLevel {
  safe,
  low,
  medium,
  high,
  critical,
}

class ThreatIndicator {
  final ThreatType type;
  final String description;
  final double confidence;
  final String? evidence;

  ThreatIndicator({
    required this.type,
    required this.description,
    required this.confidence,
    this.evidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
      'confidence': confidence,
      'evidence': evidence,
    };
  }

  factory ThreatIndicator.fromJson(Map<String, dynamic> json) {
    return ThreatIndicator(
      type: ThreatType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      confidence: json['confidence'].toDouble(),
      evidence: json['evidence'],
    );
  }
}

enum ThreatType {
  spam,
  phishing,
  malware,
  scam,
  socialEngineering,
  suspiciousUrl,
  maliciousAttachment,
  dataHarvesting,
  identityTheft,
  financialFraud,
}

class MessageData {
  final String id;
  final String content;
  final String sender;
  final DateTime receivedAt;
  final List<String> attachments;
  final Map<String, String> headers;

  MessageData({
    required this.id,
    required this.content,
    required this.sender,
    required this.receivedAt,
    this.attachments = const [],
    this.headers = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'receivedAt': receivedAt.toIso8601String(),
      'attachments': attachments,
      'headers': headers,
    };
  }

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'],
      content: json['content'],
      sender: json['sender'],
      receivedAt: DateTime.parse(json['receivedAt']),
      attachments: List<String>.from(json['attachments'] ?? []),
      headers: Map<String, String>.from(json['headers'] ?? {}),
    );
  }
}