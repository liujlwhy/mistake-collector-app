import 'package:equatable/equatable.dart';
import 'package:mistake_collector_app/core/models/subject.dart';

class Mistake extends Equatable {
  final String id;
  final String childId;
  final Subject subject;
  final String title;
  final String? description;
  final String? imagePath;
  final String? extractedText;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;
  final int reviewCount;
  final int difficulty; // 1-5 难度等级
  final bool isMastered; // 是否已掌握
  
  const Mistake({
    required this.id,
    required this.childId,
    required this.subject,
    required this.title,
    this.description,
    this.imagePath,
    this.extractedText,
    required this.createdAt,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.difficulty = 1,
    this.isMastered = false,
  });
  
  @override
  List<Object?> get props => [
        id,
        childId,
        subject,
        title,
        description,
        imagePath,
        extractedText,
        createdAt,
        lastReviewedAt,
        reviewCount,
        difficulty,
        isMastered,
      ];
      
  Mistake copyWith({
    String? id,
    String? childId,
    Subject? subject,
    String? title,
    String? description,
    String? imagePath,
    String? extractedText,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    int? reviewCount,
    int? difficulty,
    bool? isMastered,
  }) {
    return Mistake(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      difficulty: difficulty ?? this.difficulty,
      isMastered: isMastered ?? this.isMastered,
    );
  }
}
