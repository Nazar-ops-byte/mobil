import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/dump_model.dart';
import '../services/local_storage_service.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';

class AddDumpScreen extends StatefulWidget {
  const AddDumpScreen({super.key});

  @override
  State<AddDumpScreen> createState() => _AddDumpScreenState();
}

class _AddDumpScreenState extends State<AddDumpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final LocalStorageService _storageService = LocalStorageService();
  final ImageService _imageService = ImageService();

  File? _selectedImage;
  String? _imagePath;

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  bool _showOverlay = false;
  bool _saved = false;

  DumpModel? _lastSavedDump;

  String _tag = 'overthink';
  String _emoji = '😐';
  String _title = '';
  String _message = '';

  final Map<String, String> moods = {
    'overthink': '😐',
    'stres': '😣',
    'öfke': '😡',
    'kaygı': '😟',
    'mutlu': '🙂',
  };

  @override
  void initState() {
    super.initState();
    _loadMood();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadMood() async {
    final mood = await _storageService.getMood();
    if (!mounted) return;
    setState(() => _tag = mood);
  }

  Future<void> _pickCamera() async {
    final path = await _imageService.pickFromCamera();
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imagePath = path;
        _selectedImage = File(path);
      });
    }
  }

  Future<void> _pickGallery() async {
    final path = await _imageService.pickFromGallery();
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imagePath = path;
        _selectedImage = File(path);
      });
    }
  }

  Future<void> _saveDump() async {
    if (_textController.text.trim().isEmpty) return;
    if (_saved) return;

    final String? finalImagePath =
        (_imagePath != null && File(_imagePath!).existsSync())
            ? _imagePath
            : null;

    final dump = DumpModel(
      id: const Uuid().v4(),
      text: _textController.text.trim(),
      tag: _tag,
      mood: moods[_tag] ?? '😐',
      createdAt: DateTime.now(),
      imagePath: finalImagePath, // 🔥 ARTIK KESİN
    );

    await _storageService.addDump(dump);
    await _storageService.saveMood(_tag);

    _saved = true;
    _lastSavedDump = dump;

    _prepareFeedback();
    HapticFeedback.lightImpact();

    setState(() => _showOverlay = true);
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), _closeOverlay);
  }

  void _prepareFeedback() {
    _emoji = moods[_tag] ?? '😐';
    _title = 'Kaydedildi';
    _message = 'Düşüncen güvenle saklandı.';
  }

  Future<void> _discardDump() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emin misin?'),
        content: const Text('Bu dump kaydedilmeyecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bırak'),
          ),
        ],
      ),
    );

    if (ok == true) {
      Navigator.pop(context);
    }
  }

  void _closeOverlay() {
    _controller.reverse().then((_) {
      Navigator.pop(context, _lastSavedDump);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Yeni Dump')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ne düşünüyorsun?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Aklından geçenleri buraya bırak...',
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickCamera,
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _pickGallery,
                    ),
                  ],
                ),

                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _discardDump,
                        child: const Text('Bırak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveDump,
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_showOverlay)
            FadeTransition(
              opacity: _opacity,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6D8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(_title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_message, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
