import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      backgroundColor: Color(0xFFEAF5FB),
      body: Stack(
        children: [
          Stack(
            children: [
              Visibility(
                visible: (!isKeyboard ? true : false), // bool
                child: Positioned(
                  top: 0,
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
                top: 0,
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
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: !isKeyboard ? 210 : 70,),
                Image.asset('assets/logo.png'), // Logo
                SizedBox(height: 10,),
                Container(
                  child: Text(
                    'Log in to your Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 45,),
                // Input Boxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student No.
                    Container(
                      child: Text('Student No.'),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      height: 40,
                      width: 300,
                      child: TextField( // Input box
                        style: TextStyle(fontSize: 14),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter Student No.', // Placeholder
                          hintStyle: TextStyle(
                            color: Colors.grey, // Change placeholder color
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_2_outlined, // Add icon to the placeholder
                            color: Colors.grey, // Change the color of the icon
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
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    // Password
                    Container(child: Text('Password'),),
                    SizedBox(height: 5,),
                    SizedBox(
                      height: 40,
                      width: 300,
                      child: TextField( // Input box
                        style: TextStyle(fontSize: 14),
                        obscureText: (showPassword ? true : false),
                        decoration: InputDecoration(
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
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(165,0,0,0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size(100, 10)
                        ),
                        onPressed: () {
                          print('forgot password');
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
                SizedBox(height: 70,),
                !isKeyboard ? Container(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: Size(150, 40),
                          backgroundColor: Color(0xFF004280),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(6)
                          )
                      ),
                      onPressed: () {},
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
          )
        ],
      )
    );
  }
}
