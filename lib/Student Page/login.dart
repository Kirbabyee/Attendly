import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_1/Student Page/face_registration.dart';
import 'package:flutter_project_1/Student%20Page/dashboard.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

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
                    top: screenHeight > 370 ? 0 : -50,
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
                  top: screenHeight > 370 ? 0 : -50,
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
                    SizedBox(height: !isKeyboard ? screenHeight * .25 : 55,),
                    Image.asset(
                      width: screenWidth * 4,
                      'assets/logo.png'
                    ), // Logo
                    SizedBox(height: 10,),
                    Container(
                      child: Text(
                        'Log in to your Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * .045,),
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
                          SizedBox(height: 5,),
                          SizedBox(
                            height: screenHeight * .07,
                            width: screenWidth * .76,
                            child: TextFormField( // Input box
                              style: TextStyle(fontSize: screenHeight * .016),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                errorMaxLines: 1,
                                errorStyle: TextStyle(
                                  fontSize: 10,
                                  height: 1,
                                ),
                                hintText: 'Enter Student No.', // Placeholder
                                hintStyle: TextStyle(
                                  color: Colors.grey, // Change placeholder color
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_2_outlined, // Add icon to the placeholder
                                  color: Colors.grey, // Change the color of the icon
                                  size: screenHeight * .035,
                                ),
                                contentPadding: const EdgeInsets.symmetric( // Add padding
                                  horizontal: 10,
                                  vertical: 10,
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

                          SizedBox(height: screenHeight * .02,),
                          // Password
                          Container(
                            child: Text(
                              'Password',
                              style: TextStyle(
                                  fontSize: screenHeight * .017
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          SizedBox(
                            height: screenHeight * .07,
                            width: screenWidth * .76,
                            child: TextFormField( // Input box
                              style: TextStyle(fontSize: screenHeight * .016),
                              obscureText: (showPassword ? true : false),
                              decoration: InputDecoration(
                                errorMaxLines: 1,
                                errorStyle: TextStyle(
                                  fontSize: 10,
                                  height: 1,
                                ),
                                hintText: 'Enter Password', // Placeholder
                                hintStyle: TextStyle(
                                  color: Colors.grey, // Change placeholder color
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline, // Add icon to the placeholder
                                  color: Colors.grey, // Change the color of the icon
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric( // Add padding
                                  horizontal: 10,
                                  vertical: 10,
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
                            margin: EdgeInsets.fromLTRB(screenWidth * .47,0,0,0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot_password');
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .08,),
                    !isKeyboard ? Container(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(150, 40),
                          backgroundColor: Color(0xFF004280),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(6)
                          )
                        ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

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

                            // ✅ your real login goes here (Firebase signIn, etc.)
                            await Future.delayed(const Duration(milliseconds: 3000));

                            if (!mounted) return;

                            Navigator.pop(context); // close loading

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const Mainshell()),
                            );
                          },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
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
