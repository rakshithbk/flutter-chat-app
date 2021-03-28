import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contact_list.dart';
import '../screens/chat_screen.dart';

class ContactListWidget extends StatelessWidget {
  const ContactListWidget({
    Key key,
  }) : super(key: key);

  Widget _userAvatar(String imageURL) {
    if (imageURL == '')
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.perm_identity_rounded),
      );
    else
      return CircleAvatar(
        backgroundImage: NetworkImage(imageURL),
      );
  }

  void _navigateToChat(BuildContext context, ContactInfo contactInfo) async {
    final myUserID = FirebaseAuth.instance.currentUser.uid;
    final contactUserID = contactInfo.id;
    final chatID = (myUserID.hashCode >= contactUserID.hashCode)
        ? '$myUserID-$contactUserID'
        : '$contactUserID-$myUserID';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("before Firestore await")));
    DocumentSnapshot contactDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(contactUserID)
        .get();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("after await, ID->${contactDetails.id}")));
    ContactList.instance.updateUnreadMessage(contactInfo.id, false);
    Navigator.pushNamed(context, ChatScreen.routeName,
        arguments: {'chatID': chatID, 'contactDetails': contactDetails});
  }

  @override
  Widget build(BuildContext context) {
    List<ContactInfo> _contactList =
        Provider.of<ContactList>(context).contactList;

    return ListView.builder(
      itemCount: _contactList.length,
      // padding: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.only(left: 15, right: 15, top: 20),
      itemBuilder: (ctx, index) {
        return ListTile(
          // key: ValueKey(_contactList[index].id),
          title: Text(
            _contactList[index].name,
            style: TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            _contactList[index].lastMessage,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: _contactList[index].isUnreadMessage
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _contactList[index].isUnreadMessage
                    ? Colors.black
                    : Colors.grey[600]),
          ),
          leading: _userAvatar(_contactList[index].avatar),
          trailing: Icon(_contactList[index].isUnreadMessage
              ? Icons.mark_chat_unread
              : Icons.chat_outlined),
          onTap: () {
            _navigateToChat(context, _contactList[index]);
          },
        );
      },
    );
  }
}
