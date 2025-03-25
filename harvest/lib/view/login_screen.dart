import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/user_controller.dart';
import '../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool isSigningUp = false; 

  final UserController userController = UserController();

  Future<void> signIn() async {                                                 // Sign In Method
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign In error')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred during Sign In')),
        );
      }
    }
  }

                                                                                  
  Future<void> signUp() async {                                                // Sign Up Method
    if (nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name is required!')),
        );
      }
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImageUrl: "", 
      );

    
      await userController.addUser(newUser.uid!, newUser.name, newUser.email);    // Save user in Firestore

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New account created successfully!')),
        );
      }

      // switch back to Sign In mode after successful signup
      if (mounted) {
        setState(() {
          isSigningUp = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign Up error')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred during Sign Up')),
        );
      }
    }
  }

  
  Future<void> forgetPassword() async {                                         // Forgot Password Method
    if (emailController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email!')),
        );
      }
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to email!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSigningUp)                                                    // Show name field only in Sign Up mode(additon)
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            
            if (!isSigningUp) ...[
              ElevatedButton(onPressed: signIn, child: const Text('Sign In')),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => isSigningUp = true),
                child: const Text('Create a new account'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: forgetPassword, child: const Text('Forgot Password?')),
            ] 
            else ...[
              ElevatedButton(onPressed: signUp, child: const Text('Create Account')),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => isSigningUp = false),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
