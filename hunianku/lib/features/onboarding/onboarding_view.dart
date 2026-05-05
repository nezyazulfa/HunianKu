import 'package:flutter/material.dart';
import 'package:hunianku/features/auth/views/login_page.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color _bgColor = const Color(0xFFF1E7DB);
  final Color _btnColor = const Color(0xFF76070E);

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/ImageSatu.jpeg",
      "title": "Hunianku",
      "text": "Sebuah ruang di mana kenyamanan, keamanan, dan ketenangan berpadu menjadi satu"
    },
    {
      "image": "assets/ImageDua.jpeg",
      "title": "Hunianmu",
      "text": "Temukan ruang yang membuatmu merasa utuh, sebuah tempat yang memanggilmu pulang"
    },
    {
      "image": "assets/ImageTiga.png",
      "title": "",
      "text": "Satu langkah untuk ribuan cerita baru. Temukan kosan idaman atau pasarkan ruangmu sekarang"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            onboardingData[index]["image"]!,
                            height: index == 2 ? 150 : 250, 
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        if (onboardingData[index]["title"]!.isNotEmpty)
                          Text(
                            onboardingData[index]["title"]!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        Text(
                          onboardingData[index]["text"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Bagian tombol yang sudah diperbarui menjadi satu tombol dinamis
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        } else {
                          _pageController.jumpToPage(onboardingData.length - 1);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _btnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        // Teks otomatis berubah menjadi "Lanjut" jika berada di halaman terakhir
                        _currentPage == onboardingData.length - 1 ? "Lanjut" : "Lewati",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 8 : 8, 
      decoration: BoxDecoration(
        color: _currentPage == index ? _btnColor : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}