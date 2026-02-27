import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String icon;
  
  const Subject({
    required this.id,
    required this.name,
    required this.icon,
  });
  
  static const math = Subject(id: 'math', name: '数学', icon: 'math');
  static const chinese = Subject(id: 'chinese', name: '语文', icon: 'chinese');
  static const english = Subject(id: 'english', name: '英语', icon: 'english');
  static const physics = Subject(id: 'physics', name: '物理', icon: 'physics');
  static const chemistry = Subject(id: 'chemistry', name: '化学', icon: 'chemistry');
  static const biology = Subject(id: 'biology', name: '生物', icon: 'biology');
  
  static List<Subject> all = [
    math,
    chinese,
    english,
    physics,
    chemistry,
    biology,
  ];
  
  @override
  List<Object?> get props => [id, name, icon];
}