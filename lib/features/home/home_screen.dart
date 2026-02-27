import 'package:flutter/material.dart';
import 'package:mistake_collector_app/features/camera/camera_ocr_screen.dart';
import 'package:mistake_collector_app/features/statistics/statistics_screen.dart';

/// 主页面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _MistakeListScreen(),
    const CameraOcrScreen(childId: 'default'),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: '错题本'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: '拍照'),
          NavigationDestination(icon: Icon(Icons.analytics), label: '统计'),
        ],
      ),
    );
  }
}

/// 错题列表页面
class _MistakeListScreen extends StatelessWidget {
  const _MistakeListScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('暂无错题', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('点击底部"拍照"按钮添加错题', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
