import 'package:flutter/material.dart';
import 'package:mydiary/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {

  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌸 Pastel Pink Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDE2F3),
              Color(0xFFF7D4EC),
              Color(0xFFEEC7E7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: Container(
              width: width < 500 ? width * 0.9 : 380,
              padding: const EdgeInsets.all(22),

              // 🌸 Soft White Card
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    "Set New PIN",
                    style: TextStyle(
                      fontSize: 28,
                      color: Color(0xFFB03A75),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Your PIN must be 6 digits",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PIN Field
                  TextField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 3,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Enter 6-digit PIN",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFFB03A75),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color(0xFFB03A75),
                        ),
                        onPressed: () {
                          setState(() => passwordVisible = !passwordVisible);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.pink.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB03A75),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: savePin,
                      child: const Text(
                        "Save PIN",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        color: Color(0xFFB03A75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // SAVE PIN LOGIC
  // -------------------------------------------------------------------
  Future<void> savePin() async {
    String pin = passwordController.text.trim();

    if (pin.length != 6) {
      showSnack("PIN must be exactly 6 digits!");
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', pin);
    await prefs.setBool('remember', false);

    showSnack("PIN saved successfully!");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
