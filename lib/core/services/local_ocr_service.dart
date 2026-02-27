import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 本地 OCR 服务 - 图像处理
class LocalOcrService {
  
  /// 图像预处理
  Future<File> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('无法解码图片');
    
    image = img.grayscale(image);
    image = img.adjustColor(image, brightness: 10, contrast: 20, saturation: 0);
    
    final tempDir = await getTemporaryDirectory();
    final processedFile = File('${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await processedFile.writeAsBytes(img.encodeJpg(image, quality: 90));
    
    return processedFile;
  }
  
  /// 学科分类
  String classifySubject(String text) {
    if (text.contains(RegExp(r'[+\-×÷=]')) || text.contains('方程') || text.contains('几何')) return 'math';
    if (text.contains('古诗') || text.contains('阅读')) return 'chinese';
    return 'math';
  }
  
  void dispose() {}
}
