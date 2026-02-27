import 'package:flutter/foundation.dart';

/// 错题统计
class MistakeStatistics extends ChangeNotifier {
  int _totalMistakes = 0;
  Map<String, int> _bySubject = {};
  
  int get totalMistakes => _totalMistakes;
  Map<String, int> get bySubject => Map.unmodifiable(_bySubject);
  
  void addMistake(String subjectId) {
    _totalMistakes++;
    _bySubject[subjectId] = (_bySubject[subjectId] ?? 0) + 1;
    notifyListeners();
  }
}
