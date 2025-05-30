import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  // Login method, after successful login:
  void login() async {
    // Validate inputs first
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorCode = "Please enter both email and password";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        // Update FCM token
        // await NotificationService().updateUserFcmToken(
        //   userCredential.user!.uid,
        // );

        // // Show login success notification
        // await NotificationService().showLoginSuccessNotification();

        navigateHome();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          // Convert error codes to user-friendly messages
          switch (e.code) {
            case 'user-not-found':
              _errorCode = 'No user found with this email address.';
              break;
            case 'wrong-password':
              _errorCode = 'Incorrect password. Please try again.';
              break;
            case 'invalid-email':
              _errorCode = 'The email address is not valid.';
              break;
            case 'user-disabled':
              _errorCode = 'This account has been disabled.';
              break;
            case 'too-many-requests':
              _errorCode = 'Too many login attempts. Please try again later.';
              break;
            default:
              _errorCode = e.message ?? e.code;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorCode = "An error occurred: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 48),
              Icon(Icons.lock_outline, size: 100, color: Colors.blue[200]),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(label: Text('Email')),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
              ),
              const SizedBox(height: 24),
              _errorCode != ""
                  ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _errorCode,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  )
                  : const SizedBox(height: 0),
              OutlinedButton(
                onPressed: login,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: navigateRegister,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
