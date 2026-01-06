import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  String? emailValidator(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Email is required';

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';

    return null; // ✅ valid
  }


  bool showPassword = true;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _studentNoController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _studentNoController.dispose();
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
                      'Forgot Password',
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
                            'Student Number',
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
                            controller: _studentNoController,
                            style: TextStyle(fontSize: screenHeight * .017),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorMaxLines: 1,
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
                                Icons.person_outline, // Add icon to the placeholder
                                color: Colors.grey, // Change the color of the icon
                                size: screenHeight * .023,
                              ),
                              contentPadding: EdgeInsets.symmetric( // Add padding
                                horizontal: screenHeight * .013,
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
                              if (v.length < 10) return 'Student number is too short';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * .018),

                        // Email
                        Container(
                          child: Text(
                            'Email',
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
                            controller: _emailController,
                            style: TextStyle(fontSize: screenHeight * .017),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorMaxLines: 1,
                              errorStyle: TextStyle(
                                fontSize: screenHeight * .013,
                                height: 1,
                              ),
                              hintText: 'Enter Email', // Placeholder
                              hintStyle: TextStyle(
                                color: Colors.grey, // Change placeholder color
                                fontSize: screenHeight * .017,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined, // Add icon to the placeholder
                                color: Colors.grey, // Change the color of the icon
                                size: screenHeight * .023,
                              ),
                              contentPadding: EdgeInsets.symmetric( // Add padding
                                horizontal: screenHeight * .013,
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
                            validator: emailValidator,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, '/new_password');
                        }
                      },
                      child: Text(
                        'Email Me',
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
