import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'FAQs.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {

  int expandedIndex = -1; // ✅ Only one expands at a time

  List<FAQs> faqs = [
    FAQs(
      category: 'Network',
      question: 'How do I mark my attendance?',
      answer: 'To mark attendance, you need to:\n'
          '1. Be connected to the classroom Wi-Fi network.\n'
          '2. Select your class.\n'
          '3. Complete face verification.\n'
          '4. Submit your attendance.\n'
          'Make sure you are physically present in the classroom.',
    ),
    FAQs(category: 'Attendance', question: 'Why is my face verification failing?', answer: 'Face verification may fail due to poor lighting, camera obstruction, or if you\'re wearing sunglasses. Make sure your face is clearly visible and well-lit.'),
    FAQs(category: 'Network', question: 'What if I can’t connect to the  classroom Wi-Fi?', answer: 'Ensure Wi-Fi is enabled on your device and you\'re selecting the correct network. If issues persist, contact your instructor or IT support. The app requires classroom network connection for security purposes.'),
    FAQs(category: 'Notification', question: 'Why am I not receiving class reminders?', answer: 'Check that notifications are enabled in both the app settings and your device system settings. Also verify that you have set up class reminders with appropriate timing.'),
    FAQs(category: 'Account', question: 'How do I reset my password?', answer: 'Go to Settings > Security & Privacy > Change Password. You will need to enter your current password and then create a new one. Make sure your new password is strong and unique.'),
  ];

  Widget helpCard({
    required int index,
    required String category,
    required String question,
    required String answer,
  }) {
    final bool isExpanded = expandedIndex == index;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * .9,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header row (stable)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * .03, vertical: screenHeight * .005),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA9CBF9)),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: Color(0xFF004280), fontSize: screenHeight * .012),
                      ),
                    ),
                    SizedBox(height: screenHeight * .012),
                    Text(
                      question,
                      style: TextStyle(fontSize: screenHeight * .017, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // ✅ Arrow stays aligned nicely
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ],
          ),

          // ✅ Animated body (doesn't mess header)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                padding: EdgeInsets.only(top: screenHeight * .014),
                child: Text(
                  answer,
                  style: TextStyle(fontSize: screenHeight * .015, color: Colors.black87),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: screenHeight * .12,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * .08),
              decoration: const BoxDecoration(
                color: Color(0xFF004280),
                borderRadius: BorderRadius.vertical(
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
                      CupertinoIcons.question_circle,
                      color: Colors.white,
                      size: screenHeight * .06,
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
                          'Help & Support',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: screenHeight * .018,
                          ),
                        ),
                        SizedBox(height: screenHeight * .01),
                        Text(
                          'Get answers and assistance',
                          style: TextStyle(
                            fontSize: screenHeight * .014,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    ...faqs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: helpCard(
                          index: index,
                          category: faq.category,
                          question: faq.question,
                          answer: faq.answer,
                        ),
                      );
                    }).toList(),
                    
                    // Contact Support
                    Container(
                      width: screenWidth * .9,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusGeometry.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Support',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * .019
                            ),
                          ),
                          SizedBox(height: screenHeight * .023,),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subject',
                                  style: TextStyle(
                                    fontSize: screenHeight * .017,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Center(
                                  child: Container(
                                    width: screenWidth * .7,
                                    height: screenHeight * .033,
                                    child: TextField(
                                      style: TextStyle(
                                        fontSize: screenHeight * .012,
                                      ),
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        hintText: 'Brief description of your issue',
                                        hintStyle: TextStyle(
                                          fontSize: screenHeight * .012,
                                        ),
                                        contentPadding: EdgeInsets.all(5),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Colors.grey),
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * .023,),
                                Text(
                                  'Message',
                                  style: TextStyle(
                                    fontSize: screenHeight * .017
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Center(
                                  child: Container(
                                    width: screenWidth * .7,
                                    height: screenHeight * .13,
                                    child: TextField(
                                      textAlignVertical: TextAlignVertical.top,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null, // allows multiple lines
                                      expands: true,  // fills the SizedBox height
                                      style: TextStyle(
                                        fontSize: screenHeight * .012,
                                      ),
                                      decoration: InputDecoration(
                                          alignLabelWithHint: false,
                                          hintText: 'Describe your issue in detail...',
                                          hintStyle: TextStyle(
                                            fontSize: screenHeight * .012,
                                          ),
                                          contentPadding: EdgeInsets.all(5),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * .023,),
                                Center(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Color(0xFF004280),
                                      side: BorderSide(
                                        color: Color(0xFF004280),
                                      )
                                    ),
                                    child: Text(
                                      'Submit Request',
                                      style: TextStyle(
                                        fontSize: screenHeight * .013,
                                        color: Colors.white
                                      ),
                                    )
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .023,),
                    Text(
                      'Support Hours\n'
                      'Monday - Friday: 8:00 AM - 6:00 PM\n'
                      'Saturday - Sunday: Closed\n'
                      'For urgent issues outside business hours\n'
                      'please email support@university.edu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * .015,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: screenHeight * .023,),
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
