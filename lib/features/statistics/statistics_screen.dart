import 'package:flutter/material.dart';

/// 统计页面
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('暂无统计数据', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('添加错题后将显示统计信息', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
