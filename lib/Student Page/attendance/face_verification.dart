import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_project_1/Student Page/attendance/face_verified.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/student_information_card.dart';

import 'package:flutter_project_1/Student%20Page/dashboard.dart';

import '../student_session.dart';

class Face_Verification extends StatefulWidget {
  final String classSessionId;

  // ✅ add these (for header display)
  final String courseTitle;
  final String courseCode;
  final String professor;
  final String room;
  final String sched;
  final String classCode;

  const Face_Verification({
    super.key,
    required this.classSessionId,
    required this.courseTitle,
    required this.courseCode,
    required this.professor,
    required this.room,
    required this.sched,
    required this.classCode,
  });

  @override
  State<Face_Verification> createState() => _Face_VerificationState();
}

class _Face_VerificationState extends State<Face_Verification> {
  Future<void> _goToNextPageWithLoading() async {
    if (_navigated) return;
    _navigated = true;

    // Stop camera stream
    try {
      if (_controller?.value.isStreamingImages == true) {
        await _controller!.stopImageStream();
      }
    } catch (_) {}

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

      await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pop(); // close loading

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Face_Verified()),
    );
  }

  CameraController? _controller;
  Future<void>? _initFuture;

  late final FaceDetector _faceDetector;

  bool _processing = false;
  bool _faceAligned = false;

  Timer? _alignmentTimer;
  bool _showingModal = false;
  bool _navigated = false;

  DateTime _lastRun = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
      ),
    );

    _loadStudent();
  }

  Future<void> _loadStudent() async {
    try {
      final s = await StudentSession.get(); // cached
      if (!mounted) return;
      setState(() {
        _student = s;
        _loadingStudent = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _studentError = e.toString();
        _loadingStudent = false;
      });
    }
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

      // Prefer front camera
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

      // Start ML Kit processing
      await controller.startImageStream((image) async {
        // Throttle ~6 fps
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
            // Largest face
            faces.sort((a, b) =>
                _area(b.boundingBox).compareTo(_area(a.boundingBox)));
            final faceBox = faces.first.boundingBox;

            aligned = _isFaceInsideGuide(faceBox, metaSize);
          }

          if (!mounted) return;

          // Update UI
          if (aligned != _faceAligned) {
            setState(() => _faceAligned = aligned);
          }

          // ✅ Start delay when aligned
          if (aligned && !_navigated) {
            _alignmentTimer ??= Timer(const Duration(seconds: 2), () {
              if (!mounted || _navigated) return;
              _goToNextPageWithLoading();
            });
          }

          // ❌ Cancel delay if face moves away
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

  // Updated ML Kit conversion (new API, no planeData)
  InputImage _cameraImageToInputImage(
      CameraImage image,
      CameraDescription description,
      ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

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

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  // Mirror + more realistic thresholds (front camera fix)
  bool _isFaceInsideGuide(Rect faceBox, Size imageSize) {
    // Mirror horizontally because front camera preview is mirrored
    final mirroredFaceBox = Rect.fromLTRB(
      imageSize.width - faceBox.right,
      faceBox.top,
      imageSize.width - faceBox.left,
      faceBox.bottom,
    );

    // Guide region (match painter proportions)
    final guide = Rect.fromCenter(
      center: Offset(imageSize.width / 2, imageSize.height / 2),
      width: imageSize.width * 0.60,
      height: imageSize.height * 0.75,
    );

    final intersect = mirroredFaceBox.intersect(guide);

    final faceArea = mirroredFaceBox.width * mirroredFaceBox.height;
    final intersectArea =
        math.max(0, intersect.width) * math.max(0, intersect.height);

    if (faceArea <= 0) return false;

    final coverage = intersectArea / faceArea;

    final sizeOk = mirroredFaceBox.width > guide.width * 0.30 &&
        mirroredFaceBox.width < guide.width * 1.05 &&
        mirroredFaceBox.height > guide.height * 0.35 &&
        mirroredFaceBox.height < guide.height * 1.05;

    return coverage > 0.55 && sizeOk;
  }

  Map<String, dynamic>? _student;
  bool _loadingStudent = true;
  String? _studentError;

  Widget _buildStudentInfoCard() {
    if (_loadingStudent) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studentError != null) {
      return Text('Error: $_studentError');
    }

    final firstName = _student?['first_name']?.toString().trim();
    final middleName = _student?['middle_name']?.toString().trim();
    final lastName = _student?['last_name']?.toString().trim();

    final middleInitial =
    (middleName != null && middleName.isNotEmpty)
        ? '${middleName[0].toUpperCase()}.'
        : null;

    final name = [
      firstName,
      middleInitial,
      lastName,
    ].where((e) => e != null && e!.isNotEmpty).join(' ');

    final studentNo = '${_student?['student_number'] ?? '-'}';

    return StudentInfoCard(
      name: name.isEmpty ? '-' : name,
      studentNo: studentNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AttendlyBlueHeader(
                    onBack: true,
                    courseTitle: widget.courseTitle,
                    courseCode: widget.courseCode,
                    professor: widget.professor,
                    icon: CupertinoIcons.book,
                    iconColor: const Color(0xFFFBD600),
                  ),
                  const SizedBox(height: 20),
                  _buildStudentInfoCard(),
                  const SizedBox(height: 30),
                ],
              ),
              SizedBox(height: screenHeight * .013),
              // Face Verification card
              Container(
                padding: const EdgeInsets.all(15),
                width: screenWidth * .9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Face Verification',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * .018,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: screenHeight * .011),

                    // Grey camera box
                    Container(
                      width: screenWidth * .9,
                      height: screenHeight * .28,
                      margin: EdgeInsets.all(screenHeight * .013),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                        color: const Color(0xFFD9D9D9),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildCameraArea(),
                      ),
                    ),

                    // Status
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenHeight * .013),
                      child: Text(
                        _controller == null
                            ? 'Tap start to open camera'
                            : (_faceAligned ? 'Hold still...' : 'Align your face to the guide'),
                        style: TextStyle(
                          fontSize: screenHeight * .015,
                          fontWeight: FontWeight.w500,
                          color: _controller == null
                              ? Colors.black54
                              : (_faceAligned ? Colors.green : Colors.black54),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * .018),

                    Center(
                      child: OutlinedButton(
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
                            SizedBox(width: 10),
                            Text(
                              'Start Face Verification',
                              style: TextStyle(color: Colors.white, fontSize: screenHeight * .017),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_controller == null || _initFuture == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(CupertinoIcons.camera, size: 60, color: Color(0x501E1E1E)),
          SizedBox(height: 10),
          Text('Face Verification required', style: TextStyle(fontSize: 12)),
          SizedBox(height: 25),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Click below to start camera and verify your identity',
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final controller = _controller!;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? 1,
                height: controller.value.previewSize?.width ?? 1,
                child: CameraPreview(controller),
              ),
            ),

            // slight tint
            Container(color: Colors.black.withOpacity(0.05)),

            // Guide overlay (green when aligned)
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
