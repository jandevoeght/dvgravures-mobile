import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  String? _error;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _error = 'Geen camera gevonden op dit toestel.');
        }
        return;
      }

      final rear = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      final selected = rear.isNotEmpty ? rear.first : cameras.first;

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      final initializeFuture = controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializeFuture = initializeFuture;
      });

      await initializeFuture;
      if (mounted) setState(() {});
    } on CameraException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'CameraAccessDenied' =>
          'Geen toegang tot de camera. Geef DV Gravures cameratoegang in Instellingen.',
        'CameraAccessDeniedWithoutPrompt' =>
          'Cameratoegang is uitgeschakeld. Schakel dit in via Instellingen > Privacy en beveiliging > Camera.',
        'CameraAccessRestricted' =>
          'De camera is op dit toestel beperkt door iOS-instellingen.',
        _ => 'De camera kon niet worden geopend (${e.code}).',
      };
      setState(() => _error = message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'De camera kon niet worden geopend.');
      }
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop<XFile>(file);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto maken is mislukt (${e.code}).')),
      );
      setState(() => _capturing = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto maken is mislukt.')),
      );
      setState(() => _capturing = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Foto maken'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: _setupCamera,
                      child: const Text('Opnieuw proberen'),
                    ),
                  ],
                ),
              ),
            )
          : FutureBuilder<void>(
              future: _initializeFuture,
              builder: (context, snapshot) {
                final controller = _controller;
                if (snapshot.connectionState != ConnectionState.done ||
                    controller == null ||
                    !controller.value.isInitialized) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final previewSize = controller.value.previewSize;
                          if (previewSize == null) {
                            return CameraPreview(controller);
                          }

                          // Camera previewSize is reported in the camera sensor's
                          // natural (landscape) orientation. In portrait we swap
                          // width/height and use BoxFit.cover so the preview fills
                          // the available screen without stretching.
                          return ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: previewSize.height,
                                height: previewSize.width,
                                child: CameraPreview(controller),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: FloatingActionButton.large(
                            heroTag: 'camera_capture',
                            onPressed: _capturing ? null : _capture,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            child: _capturing
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.camera_alt, size: 34),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
