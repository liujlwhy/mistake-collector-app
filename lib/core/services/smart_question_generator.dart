import 'package:mistake_collector_app/core/models/mistake.dart';

/// 智能出题服务 - 基于错题生成相似练习题
class SmartQuestionGenerator {
  
  /// 基于错题生成相似题目
  List<GeneratedQuestion> generateSimilarQuestions(Mistake mistake, {int count = 3}) {
    final questions = <GeneratedQuestion>[];
    
    // 根据学科生成不同类型的题目
    switch (mistake.subject.id) {
      case 'math':
        questions.addAll(_generateMathQuestions(mistake, count));
        break;
      case 'chinese':
        questions.addAll(_generateChineseQuestions(mistake, count));
        break;
      case 'english':
        questions.addAll(_generateEnglishQuestions(mistake, count));
        break;
      default:
        questions.addAll(_generateGeneralQuestions(mistake, count));
    }
    
    return questions.take(count).toList();
  }
  
  /// 生成数学相似题目
  List<GeneratedQuestion> _generateMathQuestions(Mistake mistake, int count) {
    final questions = <GeneratedQuestion>[];
    final extractedText = mistake.extractedText ?? '';
    
    // 检测知识点类型
    if (extractedText.contains(RegExp(r'[+\\-×÷]'))) {
      // 计算题
      for (int i = 0; i < count; i++) {
        questions.add(GeneratedQuestion(
          id: 'math_calc_${i}',
          question: _generateCalculationQuestion(i),
          answer: '',
          difficulty: i + 1,
          knowledgePoint: '计算',
        ));
      }
    } else if (extractedText.contains(RegExp(r'(方程 | 等式|x=)'))) {
      // 方程题
      for (int i = 0; i < count; i++) {
        questions.add(GeneratedQuestion(
          id: 'math_eq_${i}',
          question: _generateEquationQuestion(i),
          answer: '',
          difficulty: i + 1,
          knowledgePoint: '解方程',
        ));
      }
    } else if (extractedText.contains(RegExp(r'(几何 | 三角形 | 圆 | 面积 | 体积)'))) {
      // 几何题
      for (int i = 0; i < count; i++) {
        questions.add(GeneratedQuestion(
          id: 'math_geo_${i}',
          question: _generateGeometryQuestion(i),
          answer: '',
          difficulty: i + 1,
          knowledgePoint: '几何',
        ));
      }
    } else {
      // 通用数学题
      for (int i = 0; i < count; i++) {
        questions.add(GeneratedQuestion(
          id: 'math_gen_${i}',
          question: '请解答第${i + 1}道练习题',
          answer: '',
          difficulty: i + 1,
          knowledgePoint: '综合',
        ));
      }
    }
    
    return questions;
  }
  
  /// 生成语文相似题目
  List<GeneratedQuestion> _generateChineseQuestions(Mistake mistake, int count) {
    final questions = <GeneratedQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(GeneratedQuestion(
        id: 'chinese_${i}',
        question: '语文练习题 ${i + 1}',
        answer: '',
        difficulty: i + 1,
        knowledgePoint: '语文综合',
      ));
    }
    
    return questions;
  }
  
  /// 生成英语相似题目
  List<GeneratedQuestion> _generateEnglishQuestions(Mistake mistake, int count) {
    final questions = <GeneratedQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(GeneratedQuestion(
        id: 'english_${i}',
        question: 'English Practice Question ${i + 1}',
        answer: '',
        difficulty: i + 1,
        knowledgePoint: 'English',
      ));
    }
    
    return questions;
  }
  
  /// 生成通用题目
  List<GeneratedQuestion> _generateGeneralQuestions(Mistake mistake, int count) {
    final questions = <GeneratedQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(GeneratedQuestion(
        id: 'general_${i}',
        question: '练习题 ${i + 1}',
        answer: '',
        difficulty: i + 1,
        knowledgePoint: '综合',
      ));
    }
    
    return questions;
  }
  
  /// 生成计算题
  String _generateCalculationQuestion(int index) {
    final a = 10 + index * 5;
    final b = 5 + index * 3;
    return '计算：$a + $b = ?';
  }
  
  /// 生成方程题
  String _generateEquationQuestion(int index) {
    final x = 5 + index;
    final b = 10 + index * 2;
    return '解方程：2x + $b = ${2 * x + b}';
  }
  
  /// 生成几何题
  String _generateGeometryQuestion(int index) {
    final side = 5 + index;
    return '一个正方形的边长是${side}cm，求它的面积。';
  }
}

/// 生成的题目
class GeneratedQuestion {
  final String id;
  final String question;
  final String answer;
  final int difficulty; // 1-5
  final String knowledgePoint;
  
  GeneratedQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.knowledgePoint,
  });
  
  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '较易';
      case 3:
        return '中等';
      case 4:
        return '较难';
      case 5:
        return '困难';
      default:
        return '中等';
    }
  }
}
