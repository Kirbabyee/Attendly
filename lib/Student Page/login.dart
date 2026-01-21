import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_1/Student Page/face_registration.dart';
import 'package:flutter_project_1/Student%20Page/dashboard.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';
import 'package:flutter_project_1/Student%20Page/two_fa_verification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_session.dart'; // adjust path kung nasaan file mo
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _locked = false;
  int _lockSeconds = 0;
  Timer? _lockTimer;

  void _startLock(int seconds) {
    _lockTimer?.cancel();
    setState(() {
      _locked = true;
      _lockSeconds = seconds;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_lockSeconds <= 1) {
        t.cancel();
        setState(() {
          _locked = false;
          _lockSeconds = 0;
        });
      } else {
        setState(() => _lockSeconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    _studentNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final supabase = Supabase.instance.client;

  bool showPassword = true;
  final _formKey = GlobalKey<FormState>();

  final _studentNoController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _loginError;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFEAF5FB),
      body: Stack(
        children: [
          Stack(
            children: [
              Visibility(
                visible: (!isKeyboard ? true : false), // bool
                child: Positioned(
                  top: screenHeight > 640 ? 0 : -50,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/Ellipse 2.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight > 640 ? 0 : -50,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/Ellipse 1.png', // Dark Blue Wave
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Container(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: !isKeyboard ? screenHeight * .24 : screenHeight * .16,),
                  Image.asset(
                      width: screenWidth * .9,
                      'assets/logo.png'
                  ), // Logo
                  SizedBox(height: screenHeight * .013,),
                  Container(
                    child: Text(
                      'Log in to your Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * .017
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * .048,),
                  // Input Boxes
                  Form( // Put to form to add validations
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student No.
                        Container(
                          child: Text(
                            'Student No.',
                            style: TextStyle(
                                fontSize: screenHeight * .017
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * .008,),
                        SizedBox(
                          height: screenHeight * .058,
                          width: screenWidth * .83,
                          child: TextFormField( // Input box
                            style: TextStyle(fontSize: screenHeight * .017),
                            onChanged: (_) {
                              if (_loginError != null) {
                                setState(() => _loginError = null);
                              }
                            },
                            controller: _studentNoController,
                            decoration: InputDecoration(
                              errorMaxLines: 1,
                              errorText: _loginError,
                              errorStyle: TextStyle(
                                fontSize: screenHeight * .013,
                                height: 1,
                              ),
                              hintText: 'Enter Student No.', // Placeholder
                              hintStyle: TextStyle(
                                color: Colors.grey, // Change placeholder color
                                fontSize: screenHeight * .017,
                              ),
                              prefixIcon: Icon(
                                Icons.person_2_outlined, // Add icon to the placeholder
                                color: Colors.grey, // Change the color of the icon
                                size: screenHeight * .023,
                              ),
                              contentPadding: EdgeInsets.symmetric( // Add padding
                                horizontal: 10,
                                vertical: screenHeight * .013,
                              ),
                              // Add border to the input box
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey
                                )
                              ),
                              focusedBorder: OutlineInputBorder(  // Change color of the border when clicked
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.black
                                )
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red
                                )
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red
                                ),
                              ),
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Student number is required';
                              if (v.length < 8) return 'Student number is too short';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * .018),
                        // Password
                        Container(child: Text(
                          'Password',
                          style: TextStyle(
                              fontSize: screenHeight * .017
                          ),
                        ),),
                        SizedBox(height: screenHeight * .008,),
                        SizedBox(
                          height: screenHeight * .058,
                          width: screenWidth * .83,
                          child: TextFormField( // Input box
                            style: TextStyle(fontSize: screenHeight * .017),
                            obscureText: (showPassword ? true : false),
                            controller: _passwordController,
                            decoration: InputDecoration(
                              errorMaxLines: 1,
                              errorStyle: TextStyle(
                                fontSize: screenHeight * .013,
                                height: 1,
                              ),
                              hintText: 'Enter Password', // Placeholder
                              hintStyle: TextStyle(
                                color: Colors.grey, // Change placeholder color
                                fontSize: screenHeight * .017,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline, // Add icon to the placeholder
                                color: Colors.grey, // Change the color of the icon
                                size: screenHeight * .023,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon((showPassword ? Icons.visibility_off : Icons.visibility), size: screenHeight * .023,),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.symmetric( // Add padding
                                horizontal: 10,
                                vertical: screenHeight * .013,
                              ),
                              // Add border to the input box
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey
                                  )
                              ),
                              focusedBorder: OutlineInputBorder(  // Change color of the border when clicked
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.black
                                  )
                              ),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.red
                                  )
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red
                                ),
                              ),
                            ),
                            validator: (value) {
                              final v = value ?? '';
                              if (v.isEmpty) return 'Password is required';
                              if (v.length < 8) return 'Minimum 8 characters';
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(screenWidth * .46,0,0,0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenHeight * .015,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * .073,),
                  !isKeyboard ? Container(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(screenHeight * .18, screenHeight * .043),
                        backgroundColor: Color(0xFF004280),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(6)
                        )
                      ),
                      onPressed: _locked ? null : () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() {
                          _loginError = null;
                        });

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Signing in...'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        try {
                          final studentNo = _studentNoController.text.trim();
                          final password = _passwordController.text;

                          // example mapping: studentNo -> email
                          final email = '$studentNo@attendly.com';

                          final res = await supabase.auth.signInWithPassword(
                            email: email,
                            password: password,
                          );

                          final uid = res.user?.id;
                          if (uid == null) {
                            throw Exception("User has no data");
                          }

                          // To check if the account is for student
                          final studentRow = await supabase
                              .from('students')
                              .select('id, terms_conditions, two_fa_enabled, email')
                              .eq('id', uid)
                              .maybeSingle();

                          if (studentRow == null) {
                            // Block login if no returns, means not a student account
                            await supabase.auth.signOut();
                            if (!mounted) return;
                            Navigator.pop(context); // close loading

                            setState(() {
                              _loginError = 'This account is not allowed in the Student app.';
                            });
                            _formKey.currentState!.validate();
                            return;
                          }

                          // ✅ reset attempts on successful login
                          try {
                            await supabase.functions.invoke(
                              'student-login-reset',
                              body: {'user_id': uid},
                            );
                          } catch (_) {
                            // ignore
                          }

                          StudentSession.clear();
                          await StudentSession.get(force: true);

                          // ✅ close loading dialog ONCE
                          if (mounted) Navigator.pop(context);

                          final rawTerms = studentRow['terms_conditions'];
                          final terms = (rawTerms is num) ? rawTerms.toInt() : int.tryParse('$rawTerms') ?? 0;

                          final twoFA = (studentRow['two_fa_enabled'] == true);
                          final emailReal = (studentRow['email'] ?? '').toString().trim();

                          // fallback kung sakaling walang email sa table
                          final emailToUse = emailReal.isNotEmpty ? emailReal : email;

                          // ✅ 2FA flow
                          if (twoFA) {
                            // 1) send OTP using email
                            try {
                              final res = await supabase.functions.invoke(
                                'send-2fa-otp',
                                body: {'email': emailToUse},
                              );

                              debugPrint(res.data);
                            } catch (_) {
                              // ok lang, user can resend inside modal
                            }

                            // 2) open OTP modal
                            final verified = await TwoFAVerificationPage.open(
                              context,
                              email: emailToUse,
                              resendSeconds: 60,
                              onResend: () async {
                                await supabase.functions.invoke(
                                  'send-2fa-otp',
                                  body: {'email': emailToUse},
                                );
                              },
                              onVerify: (otp) async {
                                final resp = await supabase.functions.invoke(
                                  'verify-2fa-otp',
                                  body: {'email': emailToUse, 'otp': otp},
                                );

                                final data = Map<String, dynamic>.from(resp.data ?? {});
                                return data['verified'] == true; // ✅
                              },
                            );

                            if (!mounted) return;

                            // cancel / failed
                            if (verified != true) {
                              await supabase.auth.signOut();
                              StudentSession.clear();
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                              return;
                            }
                          }

                          // ✅ terms after 2FA
                          if (terms != 1) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/terms_conditions', (r) => false);
                            return;
                          }

                          Navigator.of(context).pushNamedAndRemoveUntil('/face_registration', (r) => false);
                          return;
                        } on AuthException catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context);

                          setState(() {
                            _loginError = 'Invalid student number or password';
                          });
                          _formKey.currentState!.validate();

                          // ✅ call edge function to increment attempts + email user
                          try {
                            final studentNo = _studentNoController.text.trim();

                            final resp = await supabase.functions.invoke(
                              'student-login-guard',
                              body: {'student_number': studentNo},
                            );

                            final data = Map<String, dynamic>.from(resp.data ?? {});
                            final locked = data['locked'] == true;
                            final lockSeconds = (data['lock_seconds'] as num?)?.toInt() ?? 0;

                            if (locked && lockSeconds > 0) {
                              _startLock(lockSeconds); // disable button + countdown
                            }
                          } catch (_) {
                            // ignore: anti-enumeration safe
                          }
                        }
                        catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed. $e')),
                          );
                        }
                      },
                      child: Text(
                        _locked ? 'Locked ($_lockSeconds s)' : 'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * .017
                        ),
                      )
                    ),
                  ) : Container(),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
