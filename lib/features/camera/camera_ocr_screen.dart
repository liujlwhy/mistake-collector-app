import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 拍照和 OCR 识别页面
class CameraOcrScreen extends StatefulWidget {
  final String childId;
  
  const CameraOcrScreen({super.key, required this.childId});

  @override
  State<CameraOcrScreen> createState() => _CameraOcrScreenState();
}

class _CameraOcrScreenState extends State<CameraOcrScreen> {
  File? _selectedImage;
  File? _processedImage;
  bool _isProcessing = false;
  
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('选择图片失败：$e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final bytes = await _selectedImage!.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image != null) {
        image = img.grayscale(image);
        image = img.adjustColor(image, brightness: 10, contrast: 20, saturation: 0);
        
        final tempDir = await getTemporaryDirectory();
        _processedImage = File('${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await _processedImage!.writeAsBytes(img.encodeJpg(image, quality: 90));
        
        setState(() {});
        _showSaveDialog();
      }
    } catch (e) {
      _showError('处理失败：$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showSaveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存错题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_processedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_processedImage!, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            const Text('错题已处理，可以保存了'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('错题保存成功！'), backgroundColor: Colors.green),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.contain),
                  ),
                ),
              )
            else
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('请拍照或选择图片', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [CircularProgressIndicator(), SizedBox(height: 8), Text('正在处理...')],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册'),
                  ),
                  if (_selectedImage != null && !_isProcessing)
                    ElevatedButton.icon(
                      onPressed: _processImage,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('处理'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
