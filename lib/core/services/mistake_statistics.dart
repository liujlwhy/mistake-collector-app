import 'package:mistake_collector_app/core/models/mistake.dart';

/// 错题统计服务
class MistakeStatistics {
  
  /// 按学科统计错题数量
  Map<String, int> countBySubject(List<Mistake> mistakes) {
    final Map<String, int> stats = {};
    
    for (var mistake in mistakes) {
      final subjectId = mistake.subject.id;
      stats[subjectId] = (stats[subjectId] ?? 0) + 1;
    }
    
    return stats;
  }
  
  /// 按难度统计错题数量
  Map<int, int> countByDifficulty(List<Mistake> mistakes) {
    final Map<int, int> stats = {};
    
    for (var mistake in mistakes) {
      final difficulty = mistake.difficulty;
      stats[difficulty] = (stats[difficulty] ?? 0) + 1;
    }
    
    return stats;
  }
  
  /// 统计每日新增错题
  Map<String, int> countByDate(List<Mistake> mistakes) {
    final Map<String, int> stats = {};
    
    for (var mistake in mistakes) {
      final date = mistake.createdAt.toString().substring(0, 10); // YYYY-MM-DD
      stats[date] = (stats[date] ?? 0) + 1;
    }
    
    return stats;
  }
  
  /// 获取掌握程度统计
  MasteryStatistics getMasteryStatistics(List<Mistake> mistakes) {
    int mastered = 0;
    int learning = 0;
    int newMistakes = 0;
    
    for (var mistake in mistakes) {
      if (mistake.isMastered) {
        mastered++;
      } else if (mistake.reviewCount > 2) {
        learning++;
      } else {
        newMistakes++;
      }
    }
    
    return MasteryStatistics(
      mastered: mastered,
      learning: learning,
      newMistakes: newMistakes,
      total: mistakes.length,
    );
  }
  
  /// 获取最近 7 天错题趋势
  List<DailyStat> getLast7DaysTrend(List<Mistake> mistakes) {
    final now = DateTime.now();
    final stats = <DailyStat>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toString().substring(0, 10);
      
      final count = mistakes.where((m) => 
        m.createdAt.toString().substring(0, 10) == dateStr
      ).length;
      
      stats.add(DailyStat(
        date: date,
        count: count,
      ));
    }
    
    return stats;
  }
  
  /// 计算平均复习次数
  double averageReviewCount(List<Mistake> mistakes) {
    if (mistakes.isEmpty) return 0.0;
    
    final total = mistakes.fold<int>(0, (sum, m) => sum + m.reviewCount);
    return total / mistakes.length;
  }
  
  /// 获取最常错的知识点
  List<KnowledgePointStat> getTopKnowledgePoints(List<Mistake> mistakes, {int limit = 5}) {
    final Map<String, int> knowledgePoints = {};
    
    for (var mistake in mistakes) {
      // 从标题或提取的文本中提取知识点
      final text = mistake.extractedText ?? mistake.title;
      
      // 简单关键词匹配
      if (text.contains(RegExp(r'[+\\-×÷=]'))) {
        knowledgePoints['计算'] = (knowledgePoints['计算'] ?? 0) + 1;
      }
      if (text.contains(RegExp(r'(方程 | 等式)'))) {
        knowledgePoints['方程'] = (knowledgePoints['方程'] ?? 0) + 1;
      }
      if (text.contains(RegExp(r'(几何 | 三角形 | 圆)'))) {
        knowledgePoints['几何'] = (knowledgePoints['几何'] ?? 0) + 1;
      }
      if (text.contains(RegExp(r'(应用题 | 问题)'))) {
        knowledgePoints['应用题'] = (knowledgePoints['应用题'] ?? 0) + 1;
      }
    }
    
    // 排序并返回前 N 个
    final sorted = knowledgePoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).map((e) => KnowledgePointStat(
      name: e.key,
      count: e.value,
    )).toList();
  }
}

/// 掌握程度统计
class MasteryStatistics {
  final int mastered;
  final int learning;
  final int newMistakes;
  final int total;
  
  MasteryStatistics({
    required this.mastered,
    required this.learning,
    required this.newMistakes,
    required this.total,
  });
  
  double get masteryRate => total > 0 ? mastered / total : 0.0;
  double get learningRate => total > 0 ? learning / total : 0.0;
  double get newRate => total > 0 ? newMistakes / total : 0.0;
}

/// 每日统计
class DailyStat {
  final DateTime date;
  final int count;
  
  DailyStat({
    required this.date,
    required this.count,
  });
  
  String get dateLabel => '${date.month}/${date.day}';
}

/// 知识点统计
class KnowledgePointStat {
  final String name;
  final int count;
  
  KnowledgePointStat({
    required this.name,
    required this.count,
  });
}
