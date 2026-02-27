import 'package:flutter/material.dart';
import 'package:mistake_collector_app/core/models/mistake.dart';
import 'package:mistake_collector_app/core/repositories/mistake_repository.dart';
import 'package:mistake_collector_app/core/services/mistake_statistics.dart';
import 'package:provider/provider.dart';

/// 统计页面
class StatisticsScreen extends StatefulWidget {
  final String childId;
  
  const StatisticsScreen({super.key, required this.childId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Mistake>> _mistakesFuture;
  final MistakeStatistics _statistics = MistakeStatistics();

  @override
  void initState() {
    super.initState();
    _mistakesFuture = MistakeRepository().getMistakesByChild(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习统计'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Mistake>>(
        future: _mistakesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final mistakes = snapshot.data ?? [];
          
          if (mistakes.isEmpty) {
            return const Center(
              child: Text('暂无错题数据'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _mistakesFuture = MistakeRepository().getMistakesByChild(widget.childId);
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 总体统计卡片
                  _buildOverviewCard(mistakes),
                  const SizedBox(height: 16),
                  
                  // 学科分布
                  _buildSubjectCard(mistakes),
                  const SizedBox(height: 16),
                  
                  // 掌握程度
                  _buildMasteryCard(mistakes),
                  const SizedBox(height: 16),
                  
                  // 最近趋势
                  _buildTrendCard(mistakes),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOverviewCard(List<Mistake> mistakes) {
    final stats = _statistics.getMasteryStatistics(mistakes);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '总体概况',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总题数', '${stats.total}', Colors.blue),
                _buildStatItem('已掌握', '${stats.mastered}', Colors.green),
                _buildStatItem('学习中', '${stats.learning}', Colors.orange),
                _buildStatItem('新错题', '${stats.newMistakes}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectCard(List<Mistake> mistakes) {
    final subjectStats = _statistics.countBySubject(mistakes);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学科分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...subjectStats.entries.map((entry) {
              final subjectName = _getSubjectName(entry.key);
              final percentage = mistakes.isNotEmpty ? (entry.value / mistakes.length * 100).toInt() : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(subjectName),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('${entry.value}题 (${percentage}%)'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMasteryCard(List<Mistake> mistakes) {
    final mastery = _statistics.getMasteryStatistics(mistakes);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '掌握程度',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${(mastery.masteryRate * 100).toInt()}%',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const Text('已掌握率'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_statistics.averageReviewCount(mistakes).toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const Text('平均复习次数'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendCard(List<Mistake> mistakes) {
    final trend = _statistics.getLast7DaysTrend(mistakes);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '近 7 天趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trend.map((stat) {
                  final height = stat.count * 10.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${stat.count}'),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: height.clamp(4, 100),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(stat.dateLabel, style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  String _getSubjectName(String subjectId) {
    switch (subjectId) {
      case 'math':
        return '数学';
      case 'chinese':
        return '语文';
      case 'english':
        return '英语';
      case 'physics':
        return '物理';
      case 'chemistry':
        return '化学';
      default:
        return '其他';
    }
  }
}
