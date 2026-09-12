import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      final cam = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cameras!.first);
      _controller = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await _controller!.initialize();
    } catch (e) {
      // ignore
    }
    if (mounted) setState(() => _initializing = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      Navigator.pop(context, File(file.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to capture photo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_controller == null || !_controller!.value.isInitialized) return Scaffold(body: Center(child: Text('Camera unavailable')));

    return Scaffold(
      appBar: AppBar(title: const Text('Capture Photo')),
      body: Stack(children: [
        CameraPreview(_controller!),
        Positioned(bottom: 24, left: 0, right: 0, child: Center(child: FloatingActionButton(onPressed: _capture, child: const Icon(Icons.camera_alt))))
      ]),
    );
  }
}
