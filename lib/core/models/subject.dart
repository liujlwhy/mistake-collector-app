import 'package:equatable/equatable.dart';

/// 学科枚举
enum SubjectType { math, chinese, english, physics, chemistry }

/// 学科
class Subject extends Equatable {
  final String id;
  final String name;
  final IconData icon;

  const Subject({required this.id, required this.name, required this.icon});

  static const all = [
    Subject(id: 'math', name: '数学', icon: Icons.calculate),
    Subject(id: 'chinese', name: '语文', icon: Icons.menu_book),
    Subject(id: 'english', name: '英语', icon: Icons.translate),
    Subject(id: 'physics', name: '物理', icon: Icons.science),
    Subject(id: 'chemistry', name: '化学', icon: Icons.biotech),
  ];

  @override
  List<Object?> get props => [id, name];
}
