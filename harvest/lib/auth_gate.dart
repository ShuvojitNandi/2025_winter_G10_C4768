import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harvest/view/vendor_home.dart';
import 'view/login_screen.dart'; // Screen for login/sign up
import './view/home.dart';
import 'view/adding_category_product.dart';
import 'view/vendor_registration.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to changes in the authentication state (user logged in or out)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, the user is logged in
        if (snapshot.hasData) {
          /*return MyHomePage(
            title:
                'Authenticated UID: ${FirebaseAuth.instance.currentUser!.uid}',
          );*/
          return VendorRegistrationPage();
        }
        // If no user data is present, show the login screen
        return const LoginScreen();
      },
    );
  }
}
