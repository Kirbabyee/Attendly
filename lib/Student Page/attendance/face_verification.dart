import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Future<void> _showNotMatchedDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        actionsPadding: const EdgeInsets.only(bottom: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // red circle icon
            SizedBox(height: 6),
            Icon(Icons.cancel, color: Colors.red, size: 48),
            SizedBox(height: 14),
            Text(
              'Face Not Matched',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Wrong face detected. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Try again', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _verifying = false;

  String _statusText = 'Align your face to the guide';

// liveness
  bool _livenessPassed = false;
  int _blinkCount = 0;
  bool _eyesWereOpen = false;
  bool _eyesClosedOnce = false;
  DateTime _livenessStart = DateTime.fromMillisecondsSinceEpoch(0);

  static const double _eyeOpenThresh = 0.70;
  static const double _eyeClosedThresh = 0.25;
  static const Duration _livenessTimeout = Duration(seconds: 6);

// backend (set to your PC IP)
  static const String _baseUrl = 'http://192.168.254.103:8000'; // ✅ palitan mo

  void _resetLiveness() {
    _livenessPassed = false;
    _blinkCount = 0;
    _eyesWereOpen = false;
    _eyesClosedOnce = false;
    _livenessStart = DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _updateLivenessWithFace(Face face) {
    final le = face.leftEyeOpenProbability;
    final re = face.rightEyeOpenProbability;

    // minsan null
    if (le == null || re == null) return;

    final avg = (le + re) / 2.0;

    if (_livenessStart.millisecondsSinceEpoch == 0) {
      _livenessStart = DateTime.now();
    }

    if (DateTime.now().difference(_livenessStart) > _livenessTimeout) {
      _resetLiveness();
      _statusText = 'Try again: blink twice';
      return;
    }

    final eyesOpen = avg >= _eyeOpenThresh;
    final eyesClosed = avg <= _eyeClosedThresh;

    if (eyesOpen) _eyesWereOpen = true;

    // open -> closed
    if (_eyesWereOpen && eyesClosed) {
      _eyesClosedOnce = true;
    }

    // closed -> open = one blink
    if (_eyesClosedOnce && eyesOpen) {
      _blinkCount += 1;
      _eyesClosedOnce = false;

      if (mounted) {
        setState(() {
          _statusText = 'Blink ${math.min(_blinkCount + 1, 2)}/2';
        });
      }
    }

    if (_blinkCount >= 2) {
      _livenessPassed = true;
      _statusText = 'Liveness passed. Capturing…';
    }
  }

  bool _checkingAttendance = false;
  bool _alreadySubmitted = false;
  bool _alreadyModalShown = false;

  Future<void> _checkAlreadySubmitted() async {
    if (_checkingAttendance) return;
    if (_student == null) return;

    final studentId = _student?['id']?.toString();
    if (studentId == null || studentId.isEmpty) return;

    setState(() => _checkingAttendance = true);

    try {
      final res = await Supabase.instance.client
          .from('attendance')
          .select('id, status, time_in, created_at')
          .eq('session_id', widget.classSessionId)
          .eq('student_id', studentId)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;

      if (res != null) {
        _alreadySubmitted = true;

        // show modal once (after build)
        if (!_alreadyModalShown) {
          _alreadyModalShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showAlreadySubmittedModal();
          });
        }
      }
    } catch (_) {
      // optional: ignore or show snackbar
    } finally {
      if (mounted) setState(() => _checkingAttendance = false);
    }
  }

  Future<void> _showAlreadySubmittedModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, // ✅ white background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        actionsPadding: const EdgeInsets.only(bottom: 12),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Green check icon
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F4EA), // light green bg
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 36,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Title
            const Text(
              'Attendance Submitted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // ✅ Message
            const Text(
              'You already submitted your attendance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),

        actions: [
          Center(
            child: SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // balik sa previous page
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


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
      MaterialPageRoute(
        builder: (_) => Face_Verified(
          classSessionId: widget.classSessionId,
          courseTitle: widget.courseTitle,
          courseCode: widget.courseCode,
          professor: widget.professor,
        ),
      ),
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
        enableClassification: true,
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

      // ✅ check attendance after student is loaded
      await _checkAlreadySubmitted();
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

          Face? mainFace;
          if (faces.isNotEmpty && metaSize != null) {
            faces.sort((a, b) => _area(b.boundingBox).compareTo(_area(a.boundingBox)));
            mainFace = faces.first;
            final faceBox = mainFace.boundingBox;

            aligned = _isFaceInsideGuide(faceBox, metaSize);

            // ✅ attendance safety: reject multiple faces
            if (faces.length > 1) {
              aligned = false;
              _resetLiveness();
              if (mounted) setState(() => _statusText = 'Only one face at a time');
            }
          }

          if (!mounted) return;

          // Update UI
          if (aligned != _faceAligned) {
            setState(() => _faceAligned = aligned);
          }

          if (!mounted) return;

          if (!aligned) {
            _resetLiveness();
            if (_statusText != 'Align your face to the guide') {
              setState(() => _statusText = 'Align your face to the guide');
            }
            return;
          }

          // aligned
          if (!_livenessPassed && mainFace != null) {
            if (_statusText != 'Blink twice') {
              setState(() => _statusText = 'Blink twice');
            }
            _updateLivenessWithFace(mainFace);
          }

          // passed → capture + verify once
          if (_livenessPassed && !_navigated) {
            await _captureAndVerify(); // ✅ add function below
          }

          // ✅ Start delay when aligned


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

  Future<void> _captureAndVerify() async {
    if (_verifying || _navigated) return;
    _verifying = true;

    final c = _controller;
    if (c == null) return;

    try {
      // stop stream to take picture
      if (c.value.isStreamingImages) {
        await c.stopImageStream();
      }

      final file = await c.takePicture();

      final studentId = _student?['id']?.toString();
      if (studentId == null || studentId.isEmpty) {
        setState(() {
          _statusText = 'Missing student id';
          _navigated = false;
        });
        return;
      }

      // call backend verify
      final uri = Uri.parse('$_baseUrl/verify');
      final req = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = studentId
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final res = await req.send();
      final body = await res.stream.bytesToString();
      if (res.statusCode != 200) throw Exception(body);

      final json = jsonDecode(body) as Map<String, dynamic>;
      final verified = json['verified'] == true;

      if (!verified) {
        _resetLiveness();

        if (mounted) {
          setState(() {
            _statusText = 'Not matched. Try again.';
            _verifying = false;
            _navigated = false;
          });
        }

        // ✅ show notice
        await _showNotMatchedDialog();

        // ✅ restart stream
        await _restartStream();
        return;
      }

      // ✅ verified: write attendance (example)
      /*await Supabase.instance.client.from('attendance').insert({
        'session_id': widget.classSessionId,
        'student_id': studentId,
        'status': 'present',
        'time_in': DateTime.now().toIso8601String(),
      });*/

      if (!mounted) return;
      await _goToNextPageWithLoading();
    } catch (e) {
      _resetLiveness();
      if (mounted) {
        setState(() {
          _statusText = 'Error. Try again.';
          _navigated = false;
          _verifying = false;
        });
      }
      await _restartStream();
    }
  }

  Future<void> _restartStream() async {
    final c = _controller;
    if (c == null) return;

    // just call _startCamera() fresh if you prefer, but avoid re-init controller.
    // simplest: start stream again with same handler by calling _startCamera() after stop+dispose.
    // Here we re-use your existing setup by disposing and starting again.
    await _stopCamera();
    await _startCamera();
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
                        _controller == null ? 'Tap start to open camera' : _statusText,
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
                          if (_alreadySubmitted) {
                            if (!_alreadyModalShown) {
                              _alreadyModalShown = true;
                              _showAlreadySubmittedModal();
                            }
                            return;
                          }

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
