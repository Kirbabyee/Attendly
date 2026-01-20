import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_session.dart';
import 'mainshell.dart';
import '../main.dart'; // LandingPage

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final supabase = Supabase.instance.client;

  final _scroll = ScrollController();
  bool _reachedBottom = false;

  bool _saving = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    // ✅ if content is short and doesn't scroll, unlock accept
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      if (_scroll.position.maxScrollExtent <= 8) {
        setState(() => _reachedBottom = true);
      }
    });
  }

  void _onScroll() {
    if (_reachedBottom) return;
    if (!_scroll.hasClients) return;

    final max = _scroll.position.maxScrollExtent;
    final cur = _scroll.offset;

    if (max <= 8) {
      setState(() => _reachedBottom = true);
      return;
    }

    // unlock when close to bottom
    if ((max - cur) < 24) {
      setState(() => _reachedBottom = true);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    if (!_reachedBottom || _saving) return;

    setState(() {
      _saving = true;
      _err = null;
    });

    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) throw Exception("Not logged in");

      await supabase.from('students').update({'terms_conditions': 1}).eq('id', uid);

      StudentSession.clear();
      try {
        await StudentSession.get(force: true);
      } catch (_) {}

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Mainshell()),
            (route) => false,
      );
    } catch (e) {
      if (mounted) setState(() => _err = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _decline() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingPage()),
          (route) => false,
    );
  }

  // --- small helpers for formatted text ---
  Widget _h1(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
  );

  Widget _muted(String t) => Text(
    t,
    style: const TextStyle(fontSize: 12, color: Colors.black54),
  );

  Widget _p(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(fontSize: 13.2, height: 1.55)),
  );

  Widget _secTitle(String t) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
  );

  Widget _bullet(String t) => Padding(
    padding: const EdgeInsets.only(left: 6, bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("•  ", style: TextStyle(fontSize: 13.2, height: 1.55)),
        Expanded(child: Text(t, style: const TextStyle(fontSize: 13.2, height: 1.55))),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FB),
      body: Stack(
        children: [
          // ✅ dim overlay (modal feel)
          Container(color: Colors.black.withOpacity(0.35)),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 320,               // ✅ smaller
                maxHeight: size.height * 0.72, // ✅ smaller
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // header with X
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Terms & Conditions",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // scrollable content
                    Expanded(
                      child: Scrollbar(
                        controller: _scroll,
                        child: SingleChildScrollView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _muted("Last updated: 4 October 2023"),
                              const SizedBox(height: 10),

                              _p(
                                "Please read these terms and conditions (\"terms and conditions\", \"terms\") carefully before using Attendly (\"application\", \"app\", \"service\").",
                              ),

                              _secTitle("1. Terms of Service"),
                              _p(
                                "Welcome to Attendly. By accessing or using the Attendly system, you agree to comply with and be bound by these Terms of Service. If you do not agree with these terms, please refrain from using the system.",
                              ),
                              _p(
                                "Attendly is an attendance monitoring system designed for academic use. The system verifies attendance through network-based detection, hardware-assisted presence validation, and biometric face verification. Users are expected to use the system solely for its intended educational purpose.",
                              ),

                              _secTitle("2. Privacy Policy"),
                              _p(
                                "Attendly is committed to protecting user privacy and handling personal data responsibly. This policy explains how information is collected, used, and safeguarded within the system.",
                              ),

                              _secTitle("Information Collected"),
                              _bullet("Student and professor identification details (e.g., name, ID, assigned classes)."),
                              _bullet("Device identifiers used for presence validation."),
                              _bullet("Facial biometric data captured for face verification."),
                              _bullet("Attendance timestamps and class-related records."),
                              _p(
                                "No personal contact information such as personal email addresses, home addresses, or unrelated personal data is collected.",
                              ),

                              _secTitle("Use of Information"),
                              _bullet("Verifying student identity and physical presence."),
                              _bullet("Recording and managing attendance."),
                              _bullet("Supporting academic and administrative processes."),
                              _p(
                                "Biometric data is processed solely for identity verification and is not used for any other purpose.",
                              ),

                              _secTitle("Data Protection"),
                              _p(
                                "Facial data is stored as encrypted templates rather than raw images whenever possible. All system data is protected through access controls and is accessible only to authorized personnel such as administrators and instructors.",
                              ),

                              _secTitle("Data Sharing"),
                              _p("Attendly does not sell, rent, or share user data with third parties."),

                              _secTitle("Policy Updates"),
                              _p(
                                "This policy may be updated to reflect system improvements or regulatory requirements. Users will be informed of significant changes through the system.",
                              ),

                              // a tiny spacer so “bottom detect” is reliable
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (_err != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(_err!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),

                    // footer buttons (like your sample)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _saving ? null : _decline,
                              child: const Text("Decline", style: TextStyle(color: Colors.black),),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_reachedBottom && !_saving) ? _accept : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004280), // ✅ back to your theme blue
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFF004280).withOpacity(0.35),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : Text(_reachedBottom ? "Accept" : "Scroll"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
