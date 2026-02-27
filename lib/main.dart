import 'package:flutter/material.dart';
import 'package:mistake_collector_app/core/app_router.dart';
import 'package:mistake_collector_app/core/constants/app_theme.dart';
import 'package:mistake_collector_app/core/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化通知服务
  await NotificationService().init();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppRouter(),
      child: const MistakeCollectorApp(),
    ),
  );
}

class MistakeCollectorApp extends StatelessWidget {
  const MistakeCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '错题集',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: context.watch<AppRouter>().config,
    );
  }
}