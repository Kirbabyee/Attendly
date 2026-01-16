import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../mainshell.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
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

  Future<void> _handlePasswordChange() async {
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
          title: Icon(Icons.check_circle_outline, color: Colors.green, size: 50,),
          content: const Text(
            'Your password has been changed successfully.',
            textAlign: TextAlign.center,
          ),
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: screenHeight * .103,
              padding: EdgeInsets.symmetric(horizontal: screenHeight * .033),
              decoration: BoxDecoration(
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
                      borderRadius: BorderRadiusGeometry.circular(7),
                      color: Color(0x30FFFFFF),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: screenHeight * .053,
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                    height: screenHeight * .06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenHeight * .018,
                          ),
                        ),
                        SizedBox(height: screenHeight * .01),
                        Text(
                          'Manage your preferences',
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * .023,),
            Container(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const Mainshell(initialIndex: 3,)),
                      );
                    },
                    icon: Icon(CupertinoIcons.arrow_left, size: screenHeight * .023,)
                  ),
                  Text('Back', style: TextStyle(fontSize: screenHeight * .017),)
                ],
              ),
            ),
            SizedBox(height: screenHeight * .023,),
            Container(
              width: screenWidth * .9,
              padding: EdgeInsets.all(screenHeight * .018),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadiusGeometry.circular(8),
                color: Colors.white
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.lock,
                          size: screenHeight * .023,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: screenHeight * .015,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * .023,),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current password', style: TextStyle(fontSize: screenHeight * .015),),
                          SizedBox(height: screenHeight * .008,),
                          SizedBox(
                            width: screenWidth * .75,
                            height: screenHeight * .061,
                            child: TextFormField(
                              controller: _currentPassword,
                              obscureText: _showCurrentPassword ? false : true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Current password is required';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: screenHeight * .015,
                              ),
                              decoration: InputDecoration(
                                errorMaxLines: 1,
                                errorStyle: TextStyle(
                                  fontSize: screenHeight * .013,
                                ),
                                contentPadding: EdgeInsets.all(screenHeight * .013), // Padding inside the inputbar
                                filled: true,
                                fillColor: Color(0x50D9D9D9),
                                hintText: 'Enter current password',
                                hintStyle: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _showCurrentPassword = !_showCurrentPassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1
                                  ),
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .023,),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New password', style: TextStyle(fontSize: screenHeight * .015),),
                          SizedBox(height: screenHeight * .008),
                          SizedBox(
                            width: screenWidth * .75,
                            height: screenHeight * .061,
                            child: TextFormField(
                              controller: _newPassword,
                              obscureText: _showNewPassword ? false : true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'New password is required';
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: screenHeight * .015,
                              ),
                              decoration: InputDecoration(
                                errorMaxLines: 1,
                                errorStyle: TextStyle(
                                  fontSize: screenHeight * .013,
                                ),
                                contentPadding: EdgeInsets.all(screenHeight * .013), // Padding inside the inputbar
                                filled: true,
                                fillColor: Color(0x50D9D9D9),
                                hintText: 'Enter new password',
                                hintStyle: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _showNewPassword = !_showNewPassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1
                                  ),
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .023,),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Confirm password', style: TextStyle(fontSize: screenHeight * .015),),
                          SizedBox(height: screenHeight * .008,),
                          SizedBox(
                            width: screenWidth * .75,
                            height: screenHeight * .061,
                            child: TextFormField(
                              controller: _confirmPassword,
                              obscureText: _showConfirmPassword ? false : true,
                              validator: (value) {
                                if ((value == null || value.isEmpty) && !_newPassword.text.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if(value != _newPassword.text) return 'Password must match';
                                return null;
                              },
                              style: TextStyle(
                                fontSize: screenHeight * .015,
                              ),
                              decoration: InputDecoration(
                                errorMaxLines: 1,
                                errorStyle: TextStyle(
                                  fontSize: screenHeight * .013,
                                ),
                                contentPadding: EdgeInsets.all(screenHeight * .013), // Padding inside the inputbar
                                filled: true,
                                fillColor: Color(0x50D9D9D9),
                                suffixIcon: IconButton(
                                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword = !_showConfirmPassword;
                                    });
                                  },
                                ),
                                hintText: 'Confirm new password',
                                hintStyle: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1
                                  ),
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .013,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF043B6F),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8)
                          )
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // All inputs valid
                          _handlePasswordChange();
                        }
                      },
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * .017
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
