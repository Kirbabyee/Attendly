import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_1/Student Page/face_registration.dart';
import 'package:flutter_project_1/Student%20Page/dashboard.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_session.dart'; // adjust path kung nasaan file mo

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final supabase = Supabase.instance.client;

  bool showPassword = true;
  final _formKey = GlobalKey<FormState>();

  final _studentNoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _studentNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                      onPressed: () async {
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
                          final studentNo = _studentNoController.text.trim().toLowerCase();
                          final password = _passwordController.text;

                          // example mapping: studentNo -> email
                          final email = '$studentNo@attendly.com';

                          await supabase.auth.signInWithPassword(
                            email: email,
                            password: password,
                          );

                          StudentSession.clear();
                          // preload student info BEFORE closing loading
                          await StudentSession.get(force: true);

                          // optional: maliit na delay para smooth UI (pwede tanggalin)
                          // await Future.delayed(const Duration(milliseconds: 200));

                          if (!mounted) return;
                          Navigator.pop(context); // close loading ONLY kapag ready na

                          Navigator.of(context).pushNamedAndRemoveUntil('/mainshell', (route) => false);

                        } on AuthException catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context);

                          final msg = e.message.toLowerCase();

                          setState(() {
                            _loginError = 'Invalid student number or password';
                          });

                          // force redraw + show red text immediately
                          _formKey.currentState!.validate();
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed. $e')),
                          );
                        }
                      },
                      child: Text(
                        'Sign In',
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
