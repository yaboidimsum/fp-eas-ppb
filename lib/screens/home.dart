import 'package:fp_recipe/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_recipe/models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
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
                  title: const Text('Profile'),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => logout(context),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 70),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${snapshot.data?.email}'),
                      const SizedBox(height: 32),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const ListTile(
                                leading: Icon(Icons.notifications),
                                title: Text('Notifications'),
                                trailing: Icon(Icons.chevron_right),
                              ),
                              const Divider(),
                              const ListTile(
                                leading: Icon(Icons.settings),
                                title: Text('Settings'),
                                trailing: Icon(Icons.chevron_right),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(
                                  Icons.exit_to_app,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () => logout(context),
                              ),
                            ],
                          ),
                        ),
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
