import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mistake_collector_app/core/models/mistake.dart';
import 'package:mistake_collector_app/core/models/child.dart';
import 'package:mistake_collector_app/core/repositories/mistake_repository.dart';
import 'package:mistake_collector_app/core/repositories/child_repository.dart';

/// 云同步服务 - 实现多设备数据同步
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _userId;
  StreamSubscription? _syncSubscription;
  bool _isInitialized = false;

  /// 初始化 Firebase 和匿名登录
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Firebase 初始化（在 main.dart 中已调用）
      
      // 匿名登录（无需用户注册）
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      
      _userId = _auth.currentUser?.uid;
      _isInitialized = true;
      
      // 启动实时同步监听
      _startRealtimeSync();
      
      print('云同步已初始化，用户 ID: $_userId');
    } catch (e) {
      print('云同步初始化失败：$e');
      // 降级为纯本地模式
      _isInitialized = false;
    }
  }

  /// 启动实时同步监听
  void _startRealtimeSync() {
    if (_userId == null) return;
    
    // 监听云端错题变化，同步到本地
    _syncSubscription = _firestore
        .collection('users')
        .doc(_userId)
        .collection('mistakes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _syncFromCloud(snapshot);
    });
    
    // 监听云端孩子信息变化
    _firestore
        .collection('users')
        .doc(_userId)
        .collection('children')
        .snapshots()
        .listen((snapshot) {
      _syncChildrenFromCloud(snapshot);
    });
  }

  /// 从云端同步错题到本地
  void _syncFromCloud(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // 检查是否已在本地存在
      // TODO: 实现本地数据库的更新逻辑
      print('云端错题同步：${data['title']}');
    }
  }

  /// 从云端同步孩子信息到本地
  void _syncChildrenFromCloud(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      print('云端孩子信息同步：${data['name']}');
    }
  }

  /// 上传错题到云端
  Future<void> uploadMistake(Mistake mistake) async {
    if (!_isInitialized || _userId == null) {
      print('云同步未初始化，仅保存到本地');
      return;
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mistakes')
          .doc(mistake.id)
          .set({
        'id': mistake.id,
        'childId': mistake.childId,
        'subjectId': mistake.subject.id,
        'subjectName': mistake.subject.name,
        'title': mistake.title,
        'description': mistake.description,
        'extractedText': mistake.extractedText,
        'localImagePath': mistake.imagePath,
        'createdAt': mistake.createdAt.toIso8601String(),
        'lastReviewedAt': mistake.lastReviewedAt?.toIso8601String(),
        'reviewCount': mistake.reviewCount,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      print('错题已同步到云端：${mistake.title}');
    } catch (e) {
      print('上传错题失败：$e');
      // 标记为待同步，稍后重试
      // TODO: 实现重试队列
    }
  }

  /// 上传孩子信息到云端
  Future<void> uploadChild(Child child) async {
    if (!_isInitialized || _userId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('children')
          .doc(child.id)
          .set({
        'id': child.id,
        'name': child.name,
        'grade': child.grade,
        'createdAt': child.createdAt.toIso8601String(),
        'isActive': child.isActive,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      
      print('孩子信息已同步到云端：${child.name}');
    } catch (e) {
      print('上传孩子信息失败：$e');
    }
  }

  /// 从云端下载所有数据（新设备首次使用）
  Future<void> downloadAllData() async {
    if (!_isInitialized || _userId == null) {
      throw Exception('云同步未初始化');
    }
    
    try {
      // 下载孩子信息
      final childrenSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('children')
          .get();
      
      for (var doc in childrenSnapshot.docs) {
        final data = doc.data();
        print('下载孩子信息：${data['name']}');
        // TODO: 保存到本地数据库
      }
      
      // 下载错题数据
      final mistakesSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mistakes')
          .get();
      
      for (var doc in mistakesSnapshot.docs) {
        final data = doc.data();
        print('下载错题：${data['title']}');
        // TODO: 保存到本地数据库
      }
      
      print('数据下载完成');
    } catch (e) {
      print('下载数据失败：$e');
      rethrow;
    }
  }

  /// 删除云端错题
  Future<void> deleteMistakeCloud(String mistakeId) async {
    if (!_isInitialized || _userId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mistakes')
          .doc(mistakeId)
          .delete();
      
      print('云端错题已删除：$mistakeId');
    } catch (e) {
      print('删除云端错题失败：$e');
    }
  }

  /// 检查同步状态
  bool get isInitialized => _isInitialized;
  bool get isSignedIn => _auth.currentUser != null;
  
  /// 获取用户 ID
  String? get userId => _userId;

  /// 释放资源
  void dispose() {
    _syncSubscription?.cancel();
  }
}
