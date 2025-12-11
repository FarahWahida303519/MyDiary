import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mydiary/loginscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MyDiary",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE9A7B8)),
        fontFamily: "Arial",
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🌸 Soft Pink Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFF5F8),
                  Color(0xFFFAD6E2),
                  Color(0xFFF3BDD0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌬 Soft Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ✨ Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ⭐ Updated Soft Circle Icon (matches login design)
                  Container(
                    height: screenHeight * 0.20,
                    width: screenHeight * 0.20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      // ✔ Pastel soft pink background
                      color: const Color(0xFFFFF1F5),

                      // ✔ Soft floating shadow
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade100.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],

                      // ✔ Soft white border for elegant glow
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.8,
                      ),
                    ),

                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 85,
                      color: Colors.pink.shade500,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // App Title
                  Text(
                    "MyDiary",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.pink.shade700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    "Your stories. Your space.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.pink.shade600.withOpacity(0.75),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Loader
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.pink.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
