import 'package:equatable/equatable.dart';

class Child extends Equatable {
  final String id;
  final String name;
  final int grade;
  
  const Child({
    required this.id,
    required this.name,
    required this.grade,
  });
  
  @override
  List<Object?> get props => [id, name, grade];
  
  Child copyWith({
    String? id,
    String? name,
    int? grade,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
    );
  }
}