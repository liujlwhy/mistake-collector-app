import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mistake_collector_app/core/services/mistake_statistics.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const MistakeCollectorApp());
}

class MistakeCollectorApp extends StatelessWidget {
  const MistakeCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MistakeStatistics(),
      child: MaterialApp(
        title: '错题集',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
