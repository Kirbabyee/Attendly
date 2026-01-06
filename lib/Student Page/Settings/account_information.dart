import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/Student%20Page/mainshell.dart';
import 'package:image_picker/image_picker.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // optional compression
    );

    if (image == null) return;

    setState(() {
      _profileImage = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (fixed)
            Container(
              height: screenHeight * .13,
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
            SizedBox(height: screenHeight * .053,),
            Container(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(CupertinoIcons.arrow_left, size: screenHeight * .023,)
                  ),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: screenHeight * .017
                    ),
                  ),
                ],
              ),
            ),

            // Account Informaton
            SizedBox(height: screenHeight * .023,),
            Container(
              width: screenWidth * .9,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusGeometry.circular(8)
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: screenHeight * .023,
                      ),
                      SizedBox(width: 10,),
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: screenHeight * .015,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * .033,),
                  Center(
                    child: Container(
                      child: Column(
                        children: [
                          SizedBox(
<<<<<<< HEAD
                            height: screenHeight * .21,
=======
                            width: 180,
                            height: 180,
>>>>>>> 72a0865b73b61d9c2b884cb77667079fedd39f77
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(90),
                              child: _profileImage == null
                                  ? Image.asset('assets/avatar.png', fit: BoxFit.cover)
                                  : Image.file(_profileImage!, fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(height: screenHeight * .023,),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0xFF018832),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8)
                              )
                            ),
                            icon: Icon(
                              Icons.upload,
                              color: Colors.white,
                              size: screenHeight * .023,
                            ),
                            onPressed: _pickImage,
                            label: Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * .015,
                                fontWeight: FontWeight.w300
                              ),
                            )
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * .023,),
                  Center(
                    child: Container(
                      width: screenWidth * .7,
                      decoration: BoxDecoration(
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                              ),
                              Text(
                                'Alfred S. Valiente',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Student No.',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                              ),
                              Text(
                                '20231599',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Year Level',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                              ),
                              Text(
                                'Third Year',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Section',
                                style: TextStyle(
                                  fontSize: screenHeight * .015,
                                ),
                              ),
                              Text(
                                'A',
                                style: TextStyle(
                                  fontSize: screenHeight * .017,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * .013,)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
