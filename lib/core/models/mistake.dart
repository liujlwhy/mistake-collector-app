import 'package:equatable/equatable.dart';
import 'package:mistake_collector_app/core/models/subject.dart';

/// 错题
class Mistake extends Equatable {
  final String id;
  final String childId;
  final Subject subject;
  final String title;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;
  
  const Mistake({
    required this.id,
    required this.childId,
    required this.subject,
    required this.title,
    this.description,
    this.imagePath,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, childId, subject, title, createdAt];
}
