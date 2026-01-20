import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../student_session.dart';
import 'change_email.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final supabase = Supabase.instance.client;

  bool _uploading = false;
  String? _uploadError;
  String? _avatarUrl; // from DB

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Map<String, dynamic>? _student;
  bool _loadingStudent = true;
  String? _studentError;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    try {
      final s = await StudentSession.get(); // cached
      if (!mounted) return;
      setState(() {
        _student = s;
        _avatarUrl = (s?['avatar_url'] ?? '').toString().trim();
        if (_avatarUrl!.isEmpty) _avatarUrl = null;
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _profileImage = File(image.path);
    });
  }

  String _yearLevelLabel(dynamic yl) {
    // yl could be int or string, so parse safely
    final n = int.tryParse(yl?.toString() ?? '');
    switch (n) {
      case 1:
        return 'First Year';
      case 2:
        return 'Second Year';
      case 3:
        return 'Third Year';
      case 4:
        return 'Fourth Year';
      default:
        return '-';
    }
  }

  String _fullNameFromStudent(Map<String, dynamic>? s) {
    final first = (s?['first_name'] ?? '').toString().trim();
    final middle = (s?['middle_name'] ?? '').toString().trim();
    final last = (s?['last_name'] ?? '').toString().trim();

    final middleInitial = middle.isNotEmpty ? '${middle[0].toUpperCase()}.' : '';

    final full = [first, middleInitial, last]
        .where((x) => x.isNotEmpty)
        .join(' ');

    return full.isEmpty ? '-' : full;
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    setState(() {
      _uploading = true;
      _uploadError = null;
    });

    try {
      final studentId = _student?['id']?.toString();
      if (studentId == null || studentId.isEmpty) {
        throw Exception('Missing student id');
      }

      final file = _profileImage!;
      final bytes = await file.readAsBytes();

      // file extension + content type
      final ext = p.extension(file.path).toLowerCase(); // .jpg/.png
      final fileExt = (ext.isEmpty) ? '.jpg' : ext;
      final contentType = (fileExt == '.png') ? 'image/png' : 'image/jpeg';

      // storage path (overwrite same file per student)
      final uid = supabase.auth.currentUser!.id;
      final path = '$uid/avatar$fileExt';

      // ✅ Upload (upsert = overwrite)
      await supabase.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

      // ✅ Get public URL (works if bucket is PUBLIC)
      final baseUrl = supabase.storage.from('avatars').getPublicUrl(path);
      final publicUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // ✅ Save to students table
      final nowIso = DateTime.now().toUtc().toIso8601String();

      await supabase
          .from('students')
          .update({
        'avatar_url': publicUrl,
      })
          .eq('id', studentId);

      final fresh = {
        ...?_student,
        'avatar_url': publicUrl,
      };

      StudentSession.set(fresh);

      if (!mounted) return;
      setState(() {
        _student = fresh;
        _avatarUrl = publicUrl;
        _profileImage = null;
      });

      _showBottomBanner(
        context,
        message: 'Profile picture updated!',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadError = e.toString());
      _showBottomBanner(
        context,
        message: 'Upload failed: $e',
        success: false,
      );
    } finally {
      if (!mounted) return;
      setState(() => _uploading = false);
    }
  }

  void _showBottomBanner(
      BuildContext context, {
        required String message,
        bool success = true,
      }) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // auto close after 2 seconds
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: success ? const Color(0xFF018832) : const Color(0xFFB60202),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      success ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ derived display values (safe)
    final displayName = _fullNameFromStudent(_student);
    final displayStudentNo = '${_student?['student_number'] ?? '-'}';
    final displayYear = _yearLevelLabel(_student?['year_level']);
    final displaySection = '${_student?['section'] ?? '-'}';
    String displayEmail = '${_student?['email'] ?? '-'}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (fixed)
            Container(
              height: screenHeight * .13,
              padding: EdgeInsets.symmetric(horizontal: screenHeight * .033),
              decoration: const BoxDecoration(
                color: Color(0xFF004280),
                borderRadius: BorderRadius.vertical(
                  top: Radius.zero,
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0x30FFFFFF),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: screenHeight * .053,
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: screenHeight * .06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenHeight * .018,
                          ),
                        ),
                        SizedBox(height: screenHeight * .013),
                        Text(
                          'Manage your preferences',
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: screenHeight * .053),

            // Back
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(CupertinoIcons.arrow_left, size: screenHeight * .023),
                ),
                Text(
                  'Back',
                  style: TextStyle(fontSize: screenHeight * .017),
                ),
              ],
            ),

            SizedBox(height: screenHeight * .023),

            // Account Information
            Container(
              width: screenWidth * .9,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: screenHeight * .023),
                      const SizedBox(width: 10),
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: screenHeight * .015,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * .033),

                  // Avatar + Upload
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          width: 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: _profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : (_avatarUrl != null
                                ? Image.network(_avatarUrl!, fit: BoxFit.cover)
                                : Image.asset('assets/avatar.png', fit: BoxFit.cover)),
                          ),
                        ),
                        SizedBox(height: screenHeight * .023),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF018832),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: _uploading
                              ? null
                              : () async {
                            await _pickImage();
                            if (_profileImage != null) {
                              await _uploadProfileImage();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_uploading) ...[
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Uploading...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * .015,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ] else ...[
                                Icon(Icons.upload, color: Colors.white, size: screenHeight * .023),
                                const SizedBox(width: 10),
                                Text(
                                  'Upload',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * .015,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (_uploadError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _uploadError!,
                            style: TextStyle(color: Colors.red, fontSize: screenHeight * .014),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * .023),

                  // ✅ Loading / Error state
                  if (_loadingStudent)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CircularProgressIndicator(),
                    )
                  else if (_studentError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Error: $_studentError',
                        style: TextStyle(color: Colors.red, fontSize: screenHeight * .014),
                      ),
                    )
                  else
                  // ✅ Info rows
                    SizedBox(
                      width: screenWidth * .7,
                      child: Column(
                        crossAxisAlignment: .end,
                        children: [
                          _infoRow('Name:', displayName, screenHeight),
                          _infoRow('Student No.:', displayStudentNo, screenHeight),
                          _infoRow('Year Level:', displayYear, screenHeight),
                          _infoRow('Section:', displaySection, screenHeight),
                          _infoRow('Email:', displayEmail, screenHeight),
                          SizedBox(height: 10,),
                          Container(
                            child: InkWell(
                              onTap: () async {
                                final newEmail = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeEmail(currentEmail: displayEmail ?? ''),
                                  ),
                                );

                                final clean = (newEmail ?? '').trim().toLowerCase();
                                if (clean.isEmpty) return;

                                // ✅ update UI immediately
                                final fresh = {
                                  ...?_student,
                                  'email': clean,
                                };

                                StudentSession.set(fresh); // ✅ update cache so next open is updated

                                if (!mounted) return;
                                setState(() {
                                  _student = fresh;
                                  displayEmail = clean;
                                });

                                // ✅ optional: re-fetch from DB to guarantee consistency (recommended)
                                await _loadStudent();
                              },
                              child: Text(
                                'Change Email?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF105698)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                        ],
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

  Widget _infoRow(String label, String value, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: screenHeight * .015)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: screenHeight * .015,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
