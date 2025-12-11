import 'package:flutter/material.dart';
import 'package:mydiary/mainscreen.dart';
import 'package:mydiary/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  bool isCheck = false;
  String password = "";

  late AnimationController _controller;
  late Animation<double> _fade;

  bool prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadPrefs();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    password = prefs.getString('password') ?? '';
    isCheck = prefs.getBool('remember') ?? false;

    if (isCheck) {
      passwordController.text = password;
    }

    setState(() {
      prefsLoaded = true;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // -----------------------------------------------------
  // UI  
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Prevents UI from building before prefs loaded (fixes lag)
    if (!prefsLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.pink),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDE2F3),
              Color(0xFFF8CEE3),
              Color(0xFFF3B7D2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: screenWidth < 500 ? screenWidth * 0.9 : 380,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,   // LIGHTER shadow = smoother UI
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter PIN",
                    style: TextStyle(
                      color: Color(0xFFB03A75),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    "Unlock your MyDiary",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // PIN field
                  TextField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,

                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Enter 6-digit PIN",
                      hintStyle: TextStyle(color: Colors.grey.shade500),

                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFFB03A75),
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.pink.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Remember Me
                  Row(
                    children: [
                      const Text("Remember Me",
                          style: TextStyle(color: Colors.black87)),
                      const Spacer(),
                      Checkbox(
                        value: isCheck,
                        activeColor: Colors.pinkAccent,
                        onChanged: (value) async {
                          if (value == true) {
                            if (passwordController.text.length < 6) {
                              showMessage("Enter 6-digit PIN first!");
                              return;
                            }
                          }

                          final prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('remember', value!);

                          if (!value) passwordController.clear();

                          setState(() => isCheck = value);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Unlock button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB03A75),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: const Text(
                        "Unlock",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      if (password.isEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      } else {
                        showEnterPinDialog();
                      }
                    },
                    child: const Text(
                      "Set / Change PIN",
                      style: TextStyle(
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

  // -----------------------------------------------------
  // LOGIN LOGIC
  // -----------------------------------------------------
  void _handleLogin() {
    if (password.isEmpty) {
      showMessage("Please set PIN first!");
      return;
    }

    if (passwordController.text == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    } else {
      showMessage("Wrong PIN!");
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // PIN Verification Dialog
  void showEnterPinDialog() {
    TextEditingController pinController = TextEditingController();
    bool visible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text("Enter PIN", textAlign: TextAlign.center),
            content: TextField(
              controller: pinController,
              obscureText: !visible,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                suffixIcon: IconButton(
                  icon: Icon(
                      visible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setStateDialog(() => visible = !visible);
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text("Unlock"),
                onPressed: () {
                  if (pinController.text == password) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    );
                  } else {
                    showMessage("Incorrect PIN!");
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
