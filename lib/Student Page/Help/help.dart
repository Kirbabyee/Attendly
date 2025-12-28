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

    return Container(
      width: 350,
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
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA9CBF9)),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: Color(0xFF004280), fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  answer,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 30),
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
                    child: const Icon(
                      CupertinoIcons.question_circle,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Get answers and assistance',
                          style: TextStyle(
                            fontSize: 11,
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
                      width: 350,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusGeometry.circular(8)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Support',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subject',
                                ),
                                SizedBox(height: 5,),
                                Center(
                                  child: Container(
                                    width: 290,
                                    height: 30,
                                    child: TextField(
                                      style: TextStyle(
                                        fontSize: 9,
                                      ),
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        hintText: 'Brief description of your issue',
                                        hintStyle: TextStyle(
                                          fontSize: 9,
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
                                SizedBox(height: 20,),
                                Text(
                                  'Message',
                                ),
                                SizedBox(height: 5,),
                                Center(
                                  child: Container(
                                    width: 290,
                                    height: 100,
                                    child: TextField(
                                      textAlignVertical: TextAlignVertical.top,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null, // allows multiple lines
                                      expands: true,  // fills the SizedBox height
                                      style: TextStyle(
                                        fontSize: 9,
                                      ),
                                      decoration: InputDecoration(
                                          alignLabelWithHint: false,
                                          hintText: 'Describe your issue in detail...',
                                          hintStyle: TextStyle(
                                            fontSize: 9,
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
                                SizedBox(height: 20,),
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
                                        fontSize: 10,
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
                    SizedBox(height: 20,),
                    Text(
                      'Support Hours\n'
                      'Monday - Friday: 8:00 AM - 6:00 PM\n'
                      'Saturday - Sunday: Closed\n'
                      'For urgent issues outside business hours\n'
                      'please email support@university.edu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20,),
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
