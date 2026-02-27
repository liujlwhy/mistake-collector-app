import 'package:flutter/material.dart';
import 'package:mistake_collector_app/core/models/child.dart';
import 'package:mistake_collector_app/core/repositories/child_repository.dart';
import 'package:mistake_collector_app/features/mistake_list/mistake_list_screen.dart';
import 'package:mistake_collector_app/features/camera/camera_ocr_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Child>> _childrenFuture;
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _childrenFuture = ChildRepository().getChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddChildDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedChildId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraOcrScreen(childId: _selectedChildId!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请先选择孩子')),
            );
          }
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('拍照识别'),
      ),
      body: FutureBuilder<List<Child>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final children = snapshot.data ?? [];
          
          if (children.isEmpty) {
            return const Center(
              child: Text('暂无孩子信息，请先添加'),
            );
          }
          
          return Column(
            children: [
              // Child selector dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedChildId ?? children.first.id,
                  items: children.map((child) {
                    return DropdownMenuItem<String>(
                      value: child.id,
                      child: Text('${child.name} (${child.grade}年级)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChildId = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: '选择孩子',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Mistake list for selected child
              Expanded(
                child: MistakeListScreen(
                  childId: _selectedChildId ?? children.first.id,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddChildDialog() {
    final nameController = TextEditingController();
    final gradeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加孩子'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                ),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: '年级',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && 
                    gradeController.text.isNotEmpty) {
                  final newChild = Child(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    grade: int.parse(gradeController.text),
                  );
                  
                  final repo = ChildRepository();
                  final children = await repo.getChildren();
                  children.add(newChild);
                  await repo.saveChildren(children);
                  
                  setState(() {
                    _childrenFuture = repo.getChildren();
                  });
                  
                  Navigator.of(context).pop();
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }
}