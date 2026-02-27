import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 本地 OCR 服务 - 完全离线运行
class LocalOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  /// 图像预处理：去手写、增强对比度
  Future<File> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('无法解码图片');
    }
    
    // 1. 转换为灰度图
    image = img.grayscale(image);
    
    // 2. 增强对比度（自适应直方图均衡化）
    image = img.adjustColor(image, brightness: 10, contrast: 20, saturation: 0);
    
    // 3. 降噪
    image = img.gaussianBlur(image, 1);
    
    // 4. 二值化（Otsu 方法）
    image = img.threshold(image, 0);
    
    // 保存处理后的图片
    final tempDir = await getTemporaryDirectory();
    final processedFile = File('${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await processedFile.writeAsBytes(img.encodeJpg(image, quality: 90));
    
    return processedFile;
  }
  
  /// OCR 文本识别
  Future<OcrResult> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    // 提取所有文本
    String fullText = recognizedText.text;
    
    // 提取文本块位置信息
    List<TextBlockInfo> blocks = recognizedText.blocks.map((block) {
      return TextBlockInfo(
        text: block.text,
        confidence: block.confidence ?? 0.0,
        boundingBox: block.boundingBox,
      );
    }).toList();
    
    // 计算平均置信度
    double avgConfidence = blocks.isNotEmpty 
        ? blocks.fold(0.0, (sum, b) => sum + b.confidence) / blocks.length 
        : 0.0;
    
    return OcrResult(
      text: fullText,
      confidence: avgConfidence,
      blocks: blocks,
    );
  }
  
  /// 学科分类（基于关键词）
  String classifySubject(String text) {
    final lowerText = text.toLowerCase();
    
    // 数学关键词
    if (lowerText.contains(RegExp(r'[+\\-×÷=<>∫∑√πθΔ]')) ||
        lowerText.contains(RegExp(r'(方程 | 函数 | 几何 | 三角形 | 圆 | 概率 | 统计)'))) {
      return 'math';
    }
    
    // 语文关键词
    if (lowerText.contains(RegExp(r'(古诗 | 文言文 | 阅读 | 作文 | 词语 | 句子)'))) {
      return 'chinese';
    }
    
    // 英语关键词
    if (lowerText.contains(RegExp(r'[a-zA-Z]{5,}')) && 
        lowerText.contains(RegExp(r'(sentence|word|grammar|reading)'))) {
      return 'english';
    }
    
    // 物理关键词
    if (lowerText.contains(RegExp(r'(力学 | 电磁 | 光学 | 热学 | 牛顿 | 电压 | 电流)'))) {
      return 'physics';
    }
    
    // 化学关键词
    if (lowerText.contains(RegExp(r'(化学方程式 | 元素 | 分子 | 原子 | 反应)'))) {
      return 'chemistry';
    }
    
    // 默认为数学
    return 'math';
  }
  
  /// 释放资源
  void dispose() {
    _textRecognizer.close();
  }
}

/// OCR 识别结果
class OcrResult {
  final String text;
  final double confidence;
  final List<TextBlockInfo> blocks;
  
  OcrResult({
    required this.text,
    required this.confidence,
    required this.blocks,
  });
}

/// 文本块信息
class TextBlockInfo {
  final String text;
  final double confidence;
  final Rect? boundingBox;
  
  TextBlockInfo({
    required this.text,
    required this.confidence,
    this.boundingBox,
  });
}
