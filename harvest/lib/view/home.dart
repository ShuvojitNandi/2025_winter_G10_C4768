import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harvest/controller/storage_controller.dart';
import 'package:harvest/controller/vendor_service.dart';

import 'package:harvest/view/components/user_profile.dart';
import 'package:harvest/view/components/vendor_tile_grid.dart';
import '../controller/user_controller.dart';
import 'all_vendor_products.dart';
import 'vendor_registration.dart';
import 'chat_home_screen.dart';
import '../controller/messaging_controller.dart' as messaging_controller;

import '../model/vendor_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.currentUser});
  final User? currentUser;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userName;
  String? profileImageUrl;
  final TextEditingController searchController = TextEditingController();

  List<String> userShops = [];

  final UserController _userController = UserController();
  final StorageController _storageController = StorageController();
  final VendorService _vendorService = VendorService();

  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();

    messaging_controller.foregroundMessageEvent.connect((message) {
      showRibbon(
          message.notification?.title ?? "", message.notification?.body ?? "");
    });

    _userProfile = UserProfile(currentUser: widget.currentUser);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (widget.currentUser != null) {
      var user = await _userController
          .fetchUserDataByEmail(widget.currentUser!.email!);

      setState(() {
        userName = user?.name ?? widget.currentUser?.displayName;
        profileImageUrl = user?.profileImageUrl;
        userShops = user?.shops ?? [];
      });
    }
  }

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightGreen,
              title: Text("Welcome, ${userName ?? 'User'}"),
              actions: [
                Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImageUrl != null &&
                                profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: (profileImageUrl == null ||
                                profileImageUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 24)
                            : null,
                      ),
                    ),
                  );
                })
              ],
              bottom: const TabBar(tabs: [
                Tab(
                  text: "All Vendors",
                ),
                Tab(
                  text: "Your Vendors",
                )
              ]),
            ),
            endDrawer: Drawer(
              child: profileDrawer(),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TabBarView(children: [userPage(), vendorPage()]),
            ),
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                switch (index) {
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatHomeScreen(),
                      ),
                    );
                }
              },
              indicatorColor: Colors.lightGreen,
              selectedIndex: 0,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.store),
                  icon: Icon(Icons.home_outlined),
                  label: 'Vendors',
                ),
                NavigationDestination(
                  icon: Badge(
                      label: Text('0'), child: Icon(Icons.messenger_sharp)),
                  label: 'Messages',
                ),
              ],
            )));
  }

  Widget vendorPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: ElevatedButton(
              onPressed: () async {
                final vendorId = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VendorRegistrationPage()),
                );
                if (vendorId != null && vendorId.isNotEmpty) {
                  await _userController.addShopToUser(
                      widget.currentUser!.uid, vendorId);
                  _fetchUserData();
                }
              },
              child: Text("Register Your Shop"),
            )),
          ],
        ),
        const SizedBox(height: 10),
        Text("Your Shops:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: VendorTileGrid(vendors: _vendorService.populate(userShops)),
        ),
      ],
    );
  }

  Widget userPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: TextFormField(
                controller: searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Search Vendors",
                  labelStyle: TextStyle(color: Colors.white70),
                  border: UnderlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              )),
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllVendorProductsPage(
                        userId: widget.currentUser!.uid,
                        userName: userName ?? 'User',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder(
            stream: _vendorService.getVendorIds(),
            builder: (context, snapshot) {
              return VendorTileGrid(
                vendors: _vendorService.getVendors(),
                filter: searchController.text,
                edit: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget profileDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: (_userProfile != null) ? _userProfile! : Container(),
        ),
        ListTile(
          title: const Text('Change Profile'),
          onTap: _pickAndUploadImage,
        ),
        ListTile(
          title: const Text('Sign Out'),
          onTap: signout,
        ),
      ],
    );
  }

  void showRibbon(String title, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(message, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }

  Future<void> _pickAndUploadImage() async {
    String? downloadUrl =
        await _storageController.pickAndUploadImage(widget.currentUser!.uid);
    if (downloadUrl == null || !downloadUrl.isNotEmpty) return;

    setState(() {
      profileImageUrl = downloadUrl;
    });

    await _userController.updateProfilePicture(
        widget.currentUser!.uid, downloadUrl);
  }
}
