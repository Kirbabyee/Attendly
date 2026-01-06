import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  Future<void> _showLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  String? emailValidator(String? value) {
    return null; // ✅ valid
  }

  bool showPassword = true;
  final _formKey = GlobalKey<FormState>();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordChange() async {
<<<<<<< HEAD
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
=======
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
    // 1. Show loading
    await _showLoading();

    // 2. Fake delay (replace with API call in real app)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Close loading
    Navigator.pop(context);

    // 4. Show success dialog
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
<<<<<<< HEAD
          title: Icon(Icons.check_circle_outline, color: Colors.green, size: screenHeight * .053,),
          content: Text(
            'Your password has been changed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenHeight * .017),
=======
          title: Icon(Icons.check_circle_outline, color: Colors.green, size: 50,),
          content: const Text(
            'Your password has been changed successfully.',
            textAlign: TextAlign.center,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
          ),
        );
      },
    );

    if (!mounted) return;

    // 5. Go to login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }



  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

=======
    final screenHeight = MediaQuery.of(context).size.width;
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
<<<<<<< HEAD
                  top: screenHeight > 640 ? 0 : -50,
=======
                  top: screenHeight > 370 ? 0 : -50,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
<<<<<<< HEAD
                top: screenHeight > 640 ? 0 : -50,
=======
                top: screenHeight > 370 ? 0 : -50,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
<<<<<<< HEAD
                  SizedBox(height: !isKeyboard ? screenHeight * .24 : screenHeight * .16,),
                  Image.asset(
                      width: screenWidth * .9,
                      'assets/logo.png'
                  ), // Logo

                  SizedBox(height: screenHeight * .013,),
=======
                  SizedBox(height: !isKeyboard && screenHeight > 370 ? 210 : 130,),
                  Image.asset(
                      width: screenHeight > 370 ? 400 : 300,
                      'assets/logo.png'
                  ), // Logo

                  SizedBox(height: 10,),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77

                  Container(
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
<<<<<<< HEAD
                        fontSize: screenHeight * .017
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * .048,),
=======
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight > 370 ? 45 : 30,),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77

                  // Input Boxes
                  Form( // Put to form to add validations
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student No.
                        Container(
                          child: Text(
                            'New Password',
                            style: TextStyle(
<<<<<<< HEAD
                                fontSize: screenHeight * .017
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * .008,),
                        SizedBox(
                          height: screenHeight * .058,
                          width: screenWidth * .83,
                          child: TextFormField( // Input box
                            obscureText: showPassword,
                            controller: _newPasswordController,
                            style: TextStyle(fontSize: screenHeight * .017),
=======
                                fontSize: screenHeight > 370 ? 14 : 12
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        SizedBox(
                          height: screenHeight > 370 ? 55 : 48,
                          width: 300,
                          child: TextFormField( // Input box
                            obscureText: showPassword,
                            controller: _newPasswordController,
                            style: TextStyle(fontSize: 14),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorMaxLines: 1,
                              errorStyle: TextStyle(
<<<<<<< HEAD
                                fontSize: screenHeight * .013,
=======
                                fontSize: 10,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                                height: 1,
                              ),
                              hintText: 'Enter new password', // Placeholder
                              hintStyle: TextStyle(
                                color: Colors.grey, // Change placeholder color
<<<<<<< HEAD
                                fontSize: screenHeight * .017,
=======
                                fontSize: 14,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline, // Add icon to the placeholder
                                color: Colors.grey, // Change the color of the icon
<<<<<<< HEAD
                                size: screenHeight * .023,
=======
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
<<<<<<< HEAD
                                icon: Icon((!showPassword ? Icons.visibility : Icons.visibility_off), size: screenHeight * .023,)
                              ),
                              contentPadding: EdgeInsets.symmetric( // Add padding
                                horizontal: screenHeight * .013,
                                vertical: screenHeight * .013,
=======
                                icon: Icon(!showPassword ? Icons.visibility : Icons.visibility_off)
                              ),
                              contentPadding: const EdgeInsets.symmetric( // Add padding
                                horizontal: 10,
                                vertical: 10,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
                              if (v.isEmpty) return 'Password is required';
                              if (v.length < 4) return 'Password is too short';
                              return null;
                            },
                          ),
                        ),

<<<<<<< HEAD
                        SizedBox(height: screenHeight * .018),
=======
                        SizedBox(height: screenHeight > 370 ? 15 : 10),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77

                        Container(
                          child: Text(
                            'Confirm Password',
                            style: TextStyle(
<<<<<<< HEAD
                                fontSize: screenHeight * .017
=======
                                fontSize: screenHeight > 370 ? 14 : 12
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        SizedBox(
<<<<<<< HEAD
                          height: screenHeight * .058,
                          width: screenWidth * .83,
                          child: TextFormField( // Input box
                            obscureText: showPassword,
                            controller: _confirmPasswordController,
                            style: TextStyle(fontSize: screenHeight * .017),
=======
                          height: screenHeight > 370 ? 55 : 48,
                          width: 300,
                          child: TextFormField( // Input box
                            obscureText: showPassword,
                            controller: _confirmPasswordController,
                            style: TextStyle(fontSize: 14),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorMaxLines: 1,
                              errorStyle: TextStyle(
<<<<<<< HEAD
                                fontSize: screenHeight * .013,
=======
                                fontSize: 10,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                                height: 1,
                              ),
                              hintText: 'Confirm your password', // Placeholder
                              hintStyle: TextStyle(
                                color: Colors.grey, // Change placeholder color
<<<<<<< HEAD
                                fontSize: screenHeight * .017,
=======
                                fontSize: 14,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline, // Add icon to the placeholder
                                color: Colors.grey, // Change the color of the icon
<<<<<<< HEAD
                                size: screenHeight * .023,
=======
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
<<<<<<< HEAD
                                icon: Icon((!showPassword ? Icons.visibility : Icons.visibility_off), size: screenHeight * .023,)
                              ),
                              contentPadding: EdgeInsets.symmetric( // Add padding
                                horizontal: screenHeight * .013,
                                vertical: screenHeight * .013,
=======
                                icon: Icon(!showPassword ? Icons.visibility : Icons.visibility_off)
                              ),
                              contentPadding: const EdgeInsets.symmetric( // Add padding
                                horizontal: 10,
                                vertical: 10,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
                              if (v.isEmpty && !_newPasswordController.text.isEmpty) return 'Confirm password is required';
                              if (v != _newPasswordController.text.trim()) return 'Password must match';
                              if (v.length < 4) return 'Password is too short';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
<<<<<<< HEAD
                  SizedBox(height: screenHeight * .073,),
                  !isKeyboard ? Container(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(screenHeight * .18, screenHeight * .043),
=======
                  SizedBox(height: 70,),
                  !isKeyboard ? Container(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(150, 40),
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                        backgroundColor: Color(0xFF004280),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(6)
                        )
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _handlePasswordChange();
                        }
                      },

                      child: Text(
                        'Email Me',
                        style: TextStyle(
                          color: Colors.white,
<<<<<<< HEAD
                          fontSize: screenHeight * .017
=======
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
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
