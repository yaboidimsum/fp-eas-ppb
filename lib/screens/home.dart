import 'package:fp_recipe/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_recipe/models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              String userName = 'User';
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                Map<String, dynamic> userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                UserModel user = UserModel.fromMap(userData);
                userName = user.name;
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Account Information'),
                  centerTitle: true,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${snapshot.data?.email}'),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => logout(context),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
