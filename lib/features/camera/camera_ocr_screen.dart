import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mistake_collector_app/core/models/mistake.dart';
import 'package:mistake_collector_app/core/models/subject.dart';
import 'package:mistake_collector_app/core/repositories/mistake_repository.dart';
import 'package:mistake_collector_app/core/services/local_ocr_service.dart';
import 'package:uuid/uuid.dart';

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
  String? _recognizedText;
  String? _subject;
  double? _confidence;
  
  final ImagePicker _picker = ImagePicker();
  final LocalOcrService _ocrService = LocalOcrService();
  final MistakeRepository _mistakeRepository = MistakeRepository();

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

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
          _recognizedText = null;
          _subject = null;
          _confidence = null;
        });
      }
    } catch (e) {
      _showError('选择图片失败：$e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // 1. 图像预处理（去手写、增强）
      _processedImage = await _ocrService.preprocessImage(_selectedImage!);
      
      // 2. OCR 识别
      final result = await _ocrService.recognizeText(_processedImage!);
      
      // 3. 学科分类
      final subjectId = _ocrService.classifySubject(result.text);
      
      setState(() {
        _recognizedText = result.text;
        _subject = subjectId;
        _confidence = result.confidence;
      });
      
      // 4. 显示保存对话框
      _showSaveDialog();
      
    } catch (e) {
      _showError('处理失败：$e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _showSaveDialog() async {
    final titleController = TextEditingController(text: '错题 ${DateTime.now().toString().substring(5, 16)}');
    String selectedSubject = _subject ?? Subject.all.first.id;
    String? notes;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('保存错题'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 题目预览
                    if (_processedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_processedImage!, height: 150, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 16),
                    
                    // 标题
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '题目标题',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 学科选择
                    DropdownButtonFormField<String>(
                      value: selectedSubject,
                      items: Subject.all.map((subject) {
                        return DropdownMenuItem(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSubject = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '学科',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 识别文本
                    if (_recognizedText != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('识别结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _recognizedText!,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '置信度：${(_confidence! * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _confidence! > 0.8 ? Colors.green : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    
                    // 备注
                    TextField(
                      maxLines: 3,
                      onChanged: (value) => notes = value,
                      decoration: const InputDecoration(
                        labelText: '备注（可选）',
                        border: OutlineInputBorder(),
                        hintText: '错误原因、知识点等',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
    
    if (result == true) {
      await _saveMistake(
        title: titleController.text,
        subjectId: selectedSubject,
        notes: notes,
      );
    }
  }

  Future<void> _saveMistake({
    required String title,
    required String subjectId,
    String? notes,
  }) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final mistake = Mistake(
        id: const Uuid().v4(),
        childId: widget.childId,
        subject: Subject.all.firstWhere((s) => s.id == subjectId),
        title: title,
        description: notes,
        imagePath: _processedImage?.path ?? _selectedImage?.path,
        extractedText: _recognizedText,
        createdAt: DateTime.now(),
      );
      
      await _mistakeRepository.saveMistake(mistake);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('错题保存成功！'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('保存失败：$e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照识别'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图片预览区域
            if (_selectedImage != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '请拍照或选择图片',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            
            // 处理状态
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('正在处理和识别...'),
                  ],
                ),
              ),
            
            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相册'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  if (_selectedImage != null && !_isProcessing)
                    ElevatedButton.icon(
                      onPressed: _processImage,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('识别'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
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
