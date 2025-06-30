import 'package:flutter/foundation.dart';
import '../models/security_models.dart';

class MessageProvider extends ChangeNotifier {
  String _currentMessage = '';
  String _currentSender = '';
  List<String> _recentMessages = [];
  List<String> _blockedSenders = [];
  List<String> _trustedSenders = [];

  String get currentMessage => _currentMessage;
  String get currentSender => _currentSender;
  List<String> get recentMessages => _recentMessages;
  List<String> get blockedSenders => _blockedSenders;
  List<String> get trustedSenders => _trustedSenders;

  /// Update current message being analyzed
  void updateCurrentMessage(String message) {
    _currentMessage = message;
    notifyListeners();
  }

  /// Update current sender
  void updateCurrentSender(String sender) {
    _currentSender = sender;
    notifyListeners();
  }

  /// Add message to recent messages
  void addRecentMessage(String message) {
    if (message.trim().isNotEmpty) {
      _recentMessages.remove(message); // Remove if already exists
      _recentMessages.insert(0, message);
      
      // Keep only last 50 messages
      if (_recentMessages.length > 50) {
        _recentMessages = _recentMessages.take(50).toList();
      }
      
      notifyListeners();
    }
  }

  /// Clear current message
  void clearCurrentMessage() {
    _currentMessage = '';
    notifyListeners();
  }

  /// Clear current sender
  void clearCurrentSender() {
    _currentSender = '';
    notifyListeners();
  }

  /// Add sender to blocked list
  void blockSender(String sender) {
    if (sender.trim().isNotEmpty && !_blockedSenders.contains(sender)) {
      _blockedSenders.add(sender);
      _trustedSenders.remove(sender); // Remove from trusted if present
      notifyListeners();
    }
  }

  /// Add sender to trusted list
  void trustSender(String sender) {
    if (sender.trim().isNotEmpty && !_trustedSenders.contains(sender)) {
      _trustedSenders.add(sender);
      _blockedSenders.remove(sender); // Remove from blocked if present
      notifyListeners();
    }
  }

  /// Remove sender from blocked list
  void unblockSender(String sender) {
    _blockedSenders.remove(sender);
    notifyListeners();
  }

  /// Remove sender from trusted list
  void untrustSender(String sender) {
    _trustedSenders.remove(sender);
    notifyListeners();
  }

  /// Check if sender is blocked
  bool isSenderBlocked(String sender) {
    return _blockedSenders.contains(sender);
  }

  /// Check if sender is trusted
  bool isSenderTrusted(String sender) {
    return _trustedSenders.contains(sender);
  }

  /// Get sender status
  SenderStatus getSenderStatus(String sender) {
    if (_trustedSenders.contains(sender)) {
      return SenderStatus.trusted;
    } else if (_blockedSenders.contains(sender)) {
      return SenderStatus.blocked;
    } else {
      return SenderStatus.unknown;
    }
  }

  /// Clear all recent messages
  void clearRecentMessages() {
    _recentMessages.clear();
    notifyListeners();
  }

  /// Clear all blocked senders
  void clearBlockedSenders() {
    _blockedSenders.clear();
    notifyListeners();
  }

  /// Clear all trusted senders
  void clearTrustedSenders() {
    _trustedSenders.clear();
    notifyListeners();
  }

  /// Import sample messages for testing
  void loadSampleMessages() {
    _recentMessages = [
      'Congratulations! You have won $1,000,000 in our lottery! Click here to claim your prize now!',
      'Urgent: Your account will be suspended. Please verify your identity immediately.',
      'Hi, this is a reminder about our meeting tomorrow at 3 PM.',
      'Free Viagra! Limited time offer! Order now and save 90%!',
      'Your Amazon order #123456 has been shipped. Track your package here.',
      'FINAL NOTICE: Your payment is overdue. Act now to avoid legal action!',
      'Team lunch is scheduled for Friday. Please confirm your attendance.',
      'You have inherited $5 million from a distant relative in Nigeria.',
      'Security Alert: Unusual login activity detected on your account.',
      'Meeting notes from today\'s project discussion are attached.',
    ];
    notifyListeners();
  }

  /// Get message statistics
  Map<String, int> getMessageStatistics() {
    return {
      'total': _recentMessages.length,
      'blockedSenders': _blockedSenders.length,
      'trustedSenders': _trustedSenders.length,
    };
  }
}

enum SenderStatus {
  trusted,
  blocked,
  unknown,
}