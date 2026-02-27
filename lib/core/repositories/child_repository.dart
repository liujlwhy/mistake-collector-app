import 'package:mistake_collector_app/core/models/child.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildRepository {
  static const _childrenKey = 'children';
  
  Future<List<Child>> getChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final childrenJson = prefs.getStringList(_childrenKey) ?? [];
    return childrenJson.map((json) => _fromJson(json)).toList();
  }
  
  Future<void> saveChildren(List<Child> children) async {
    final prefs = await SharedPreferences.getInstance();
    final childrenJson = children.map((child) => _toJson(child)).toList();
    await prefs.setStringList(_childrenKey, childrenJson);
  }
  
  String _toJson(Child child) {
    return '${child.id}|${child.name}|${child.grade}';
  }
  
  Child _fromJson(String json) {
    final parts = json.split('|');
    return Child(
      id: parts[0],
      name: parts[1],
      grade: int.parse(parts[2]),
    );
  }
}