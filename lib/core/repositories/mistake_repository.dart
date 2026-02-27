import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mistake_collector_app/core/models/mistake.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MistakeRepository {
  static const _mistakesKey = 'mistakes';
  
  Future<List<Mistake>> getMistakesByChild(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final mistakesJson = prefs.getStringList(_mistakesKey) ?? [];
    final allMistakes = mistakesJson.map((json) => _fromJson(json)).toList();
    return allMistakes.where((mistake) => mistake.childId == childId).toList();
  }
  
  Future<void> saveMistake(Mistake mistake) async {
    final prefs = await SharedPreferences.getInstance();
    final mistakesJson = prefs.getStringList(_mistakesKey) ?? [];
    
    // Remove existing mistake if it exists
    final updatedMistakes = mistakesJson
        .where((json) => !_fromJson(json).id.startsWith(mistake.id))
        .toList();
    
    // Add the new mistake
    updatedMistakes.add(_toJson(mistake));
    
    await prefs.setStringList(_mistakesKey, updatedMistakes);
  }
  
  Future<void> deleteMistake(String mistakeId) async {
    final prefs = await SharedPreferences.getInstance();
    final mistakesJson = prefs.getStringList(_mistakesKey) ?? [];
    
    final updatedMistakes = mistakesJson
        .where((json) => !_fromJson(json).id.startsWith(mistakeId))
        .toList();
    
    await prefs.setStringList(_mistakesKey, updatedMistakes);
  }
  
  String _toJson(Mistake mistake) {
    return '${mistake.id}|${mistake.childId}|${mistake.subject.id}|${mistake.title}|${mistake.description ?? ''}|${mistake.imagePath ?? ''}|${mistake.extractedText ?? ''}|${mistake.createdAt.millisecondsSinceEpoch}|${mistake.lastReviewedAt?.millisecondsSinceEpoch ?? ''}|${mistake.reviewCount}';
  }
  
  Mistake _fromJson(String json) {
    final parts = json.split('|');
    return Mistake(
      id: parts[0],
      childId: parts[1],
      subject: Subject.all.firstWhere((s) => s.id == parts[2]),
      title: parts[3],
      description: parts[4].isEmpty ? null : parts[4],
      imagePath: parts[5].isEmpty ? null : parts[5],
      extractedText: parts[6].isEmpty ? null : parts[6],
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[7])),
      lastReviewedAt: parts[8].isEmpty 
          ? null 
          : DateTime.fromMillisecondsSinceEpoch(int.parse(parts[8])),
      reviewCount: int.parse(parts[9]),
    );
  }
  
  Future<String> saveImage(File imageFile, String childId, String mistakeId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final childDir = Directory('${appDir.path}/children/$childId/mistakes');
    await childDir.create(recursive: true);
    
    final imagePath = '${childDir.path}/$mistakeId.jpg';
    final savedFile = await imageFile.copy(imagePath);
    return savedFile.path;
  }
}