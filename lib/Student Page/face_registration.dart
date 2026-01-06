import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


import 'loading_screen.dart';

class Face_Registration extends StatefulWidget {
  const Face_Registration({super.key});

  @override
  State<Face_Registration> createState() => _Face_RegistrationState();
}

class _Face_RegistrationState extends State<Face_Registration> {

  CameraController? _controller;
  Future<void>? _initFuture;

  late final FaceDetector _faceDetector;

  bool _showingModal = false;
  bool _navigated = false;
  Timer? _alignmentTimer;

  bool _processing = false;
  bool _faceAligned = false;
  DateTime _lastRun = DateTime.fromMillisecondsSinceEpoch(0);

  // Show the Success Modal
  void _showSuccessModal() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: screenHeight * .051,
              ),
            ],
          ),
          content: Text(
            'Face Successfully Registered',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenHeight * .019
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close modal
                _navigateNext();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // Navigate through the next page after the user close the modal
  void _navigateNext() async {
    if (_navigated) return;
    _navigated = true;

    // Stop camera stream
    try {
      if (_controller?.value.isStreamingImages == true) {
        await _controller!.stopImageStream();
      }
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardLoading()),
    );
  }

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
      ),
    );
  }

  @override
  void dispose() {
    _alignmentTimer?.cancel();
    _stopCamera();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _stopCamera() async {
    final c = _controller;
    if (c == null) return;

    try {
      if (c.value.isStreamingImages) {
        await c.stopImageStream();
      }
    } catch (_) {}

    try {
      await c.dispose();
    } catch (_) {}

    _controller = null;
    _initFuture = null;
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();

      // Prefer front camera for face registration
      final front =
      cameras.where((c) => c.lensDirection == CameraLensDirection.front);
      final camera = front.isNotEmpty ? front.first : cameras.first;

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // best for Android + ML Kit
      );

      setState(() {
        _controller = controller;
        _initFuture = controller.initialize();
      });

      await _initFuture;

      await controller.startImageStream((image) async {
        // Throttle (run ~6 fps)
        final now = DateTime.now();
        if (now.difference(_lastRun).inMilliseconds < 160) return;
        _lastRun = now;

        if (_processing) return;
        _processing = true;

        try {
          final inputImage =
          _cameraImageToInputImage(image, controller.description);

          final faces = await _faceDetector.processImage(inputImage);

          bool aligned = false;
          final metaSize = inputImage.metadata?.size;

          if (faces.isNotEmpty && metaSize != null) {
            // Use the largest face
            faces.sort((a, b) => _area(b.boundingBox).compareTo(_area(a.boundingBox)));
            final faceBox = faces.first.boundingBox;

            aligned = _isFaceInsideGuide(faceBox, metaSize);
          }

          if (!mounted) return;

          // Update UI
          if (aligned != _faceAligned) {
            setState(() => _faceAligned = aligned);
          }

          // Start delay when aligned
          if (aligned && !_showingModal && !_navigated) {
            _alignmentTimer ??= Timer(const Duration(seconds: 2), () {
              if (!mounted || _showingModal || _navigated) return;

              _showingModal = true;
              _showSuccessModal();
            });
          }

          // Cancel if face moves
          if (!aligned) {
            _alignmentTimer?.cancel();
            _alignmentTimer = null;
          }

        } catch (_) {
          // ignore per-frame errors
        } finally {
          _processing = false;
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  double _area(Rect r) => r.width * r.height;

  InputImage _cameraImageToInputImage(
      CameraImage image,
      CameraDescription description,
      ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final rotation =
        InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  // Check if detected face box is mostly inside the centered guide region.
  // Uses IMAGE coordinates (not UI pixels).
  bool _isFaceInsideGuide(Rect faceBox, Size imageSize) {
    // MIRROR face box horizontally (front camera fix)
    final mirroredFaceBox = Rect.fromLTRB(
      imageSize.width - faceBox.right,
      faceBox.top,
      imageSize.width - faceBox.left,
      faceBox.bottom,
    );

    // Guide area (same proportions as UI)
    final guide = Rect.fromCenter(
      center: Offset(imageSize.width / 2, imageSize.height / 2),
      width: imageSize.width * 0.60,
      height: imageSize.height * 0.75,
    );

    final intersect = mirroredFaceBox.intersect(guide);

    final faceArea =
        mirroredFaceBox.width * mirroredFaceBox.height;
    final intersectArea =
        intersect.width.clamp(0, double.infinity) *
            intersect.height.clamp(0, double.infinity);

    if (faceArea <= 0) return false;

    final coverage = intersectArea / faceArea;

    // Looser + realistic thresholds
    final sizeOk =
        mirroredFaceBox.width > guide.width * 0.30 &&
            mirroredFaceBox.width < guide.width * 1.05 &&
            mirroredFaceBox.height > guide.height * 0.35 &&
            mirroredFaceBox.height < guide.height * 1.05;

    return coverage > 0.65 && sizeOk;
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: screenWidth * .7),
              SizedBox(height: screenHeight * .023),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Face Recognition',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * .028),
                    ),
                    SizedBox(height: screenHeight * .007),
                    Text(
                      'Scan your face to register your identity',
                      style: TextStyle(fontSize: screenHeight * .015),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * .023),

              // White card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: screenHeight * .021),
                child: Column(
                  children: [
                    // Grey camera area
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: const Color(0xFFD9D9D9),
                          height: screenHeight * .28,
                          width: double.infinity,
                          child: _buildCameraArea(),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * .013),

                    // Status text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * .06),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_controller == null
                            ? 'Tap Start to open camera'
                            : (_faceAligned
                            ? 'Hold still…'
                            : 'Align your face to the guide'),
                          style: TextStyle(
                            fontSize: screenHeight * .015,
                            fontWeight: FontWeight.w500,
                            color: _controller == null
                                ? Colors.black54
                                : (_faceAligned ? Colors.green : Colors.black54),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * .019),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * .06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Face Registration Instruction:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: screenHeight * .009),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * .05),
                            child: Text(
                              '• Make sure you are in a well-lit area.\n'
                              '• Keep your face clearly visible and remove any obstructions.\n'
                              '• Look directly at the camera and follow the on-screen instructions.\n'
                              '• Blink or move your head when needed.\n'
                              '• Wait for the confirmation message before closing the app.',
                              style: TextStyle(fontSize: screenHeight * .015),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * .021),

                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF043B6F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (_controller == null) {
                          await _startCamera();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.white),
                          SizedBox(width: screenWidth * .05),
                          Text(
                            'Start Face Registration',
                            style: TextStyle(color: Colors.white, fontSize: screenHeight * .019),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * .023),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraArea() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // If camera not started yet: show placeholder
    if (_controller == null || _initFuture == null) {
      return Center(
        child: Image.asset('assets/face-scan.png', width: screenWidth * .36),
      );
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final controller = _controller!;

        // Camera + guide overlay
        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? 1,
                height: controller.value.previewSize?.width ?? 1,
                child: CameraPreview(controller),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.05)),
            IgnorePointer(
              child: CustomPaint(
                painter: FaceGuidePainter(aligned: _faceAligned),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FaceGuidePainter extends CustomPainter {
  final bool aligned;
  FaceGuidePainter({required this.aligned});

  @override
  void paint(Canvas canvas, Size size) {
    final guideColor = aligned
        ? Colors.greenAccent.withOpacity(0.95)
        : Colors.black.withOpacity(0.85);

    final cornerPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const inset = 16.0;
    const cornerLen = 26.0;

    // Top-left
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset + cornerLen, inset),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset, inset + cornerLen),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset - cornerLen, inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + cornerLen),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset + cornerLen, size.height - inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset, size.height - inset - cornerLen),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - cornerLen, size.height - inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - inset - cornerLen),
      cornerPaint,
    );

    final ovalPaint = Paint()
      ..color = aligned
          ? Colors.greenAccent.withOpacity(0.85)
          : Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.60,
      height: size.height * 0.75,
    );

    canvas.drawOval(ovalRect, ovalPaint);
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) =>
      oldDelegate.aligned != aligned;
}
