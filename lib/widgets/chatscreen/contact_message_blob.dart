import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContactMessageBlob extends StatelessWidget {
  const ContactMessageBlob({
    Key key,
    @required this.messageDetails,
    this.contactDetails,
  }) : super(key: key);

  final DocumentSnapshot messageDetails;
  final DocumentSnapshot contactDetails;

  Widget _userAvatar() {
    if (contactDetails['imageURL'] == '') {
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.perm_identity_rounded),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(contactDetails['imageURL']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _userAvatar(),
              SizedBox(
                width: 5,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    messageDetails['content'],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Text(
            DateFormat.Hm().format(messageDetails['timestamp'].toDate()),
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
