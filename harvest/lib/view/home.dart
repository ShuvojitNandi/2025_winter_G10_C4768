import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/user_controller.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.currentUser});
  final User? currentUser;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? profileImageUrl;
  String? userName;

  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  
  Future<void> _fetchUserName() async {                                         // fetching user name ; considering all user have unique email
    if (widget.currentUser != null) {
      var user = await _userController.fetchUserDataByEmail(widget.currentUser!.email!);
      setState(() {
        userName = user?.name ?? widget.currentUser?.displayName;
      });
    }
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Upload Picture"),
                onPressed: () {
                                                                          // ## IMPORTANT## will implement image upload logic later
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Delete Picture"),
                onPressed: () {
                  setState(() {
                    profileImageUrl = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Welcome ${userName ?? 'User'}"), 
        actions: [
          IconButton(onPressed: signout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _showProfileDialog,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.currentUser?.email ?? 'user@example.com', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: 4,                                                   // #### IMPORTANT ###### implemt shop tile logic 
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text("Shop ${index + 1}")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
