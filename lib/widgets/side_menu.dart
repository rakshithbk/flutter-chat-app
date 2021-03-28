import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/settings_screen.dart';

class SideMenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userDetails = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: ListView(
        children: [
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userDetails.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState != ConnectionState.done)
                return Center(child: CircularProgressIndicator());
              final DocumentSnapshot userData = userSnapshot.data;
              Widget circleAvatar;
              if (userData['imageURL'] == '')
                circleAvatar = CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.perm_identity_rounded),
                );
              else
                circleAvatar = CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(userData['imageURL']),
                );
              return UserAccountsDrawerHeader(
                accountName: Text("Name - ${userData['username']}"),
                accountEmail: Text(userData['email']),
                currentAccountPicture: circleAvatar,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                        'https://source.unsplash.com/500x300/?night,dark'),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text("Settings"),
            onTap: () {
              Navigator.pushNamed(context, SettingScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
