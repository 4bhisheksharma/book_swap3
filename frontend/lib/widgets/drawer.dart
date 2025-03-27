import 'package:book_swap/pages/profile_section.dart';
import 'package:book_swap/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final imageUrl =
      "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg?size=338&ext=jpg&ga=GA1.1.2008272138.1726876800&semt=ais_hybrid";

  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: const Text(
                  "Guest User",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                accountEmail: const Text(
                  "user@gmail.com",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileSection()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.home,
                color: Colors.white,
              ),
              title: const Text(
                "Home",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.homeRoute);
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.book_circle_fill,
                color: Colors.white,
              ),
              title: const Text(
                "Books",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.booksRoute);
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.book_solid,
                color: Colors.white,
              ),
              title: const Text(
                "Add Books",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.addBooksRoute);
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.profile_circled,
                color: Colors.white,
              ),
              title: const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.profileRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
