import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../providers/contact_list.dart';
import '../services/push_notifications.dart';
import '../widgets/chatscreen/contact_message_blob.dart';
import '../widgets/chatscreen/emoji_picker.dart';
import '../widgets/chatscreen/user_message_blob.dart';

class ChatScreen extends StatelessWidget {
  static const routeName = '/chat';

  final _chatBodyOffsetHeight = StreamController<double>();

  @override
  Widget build(BuildContext context) {
    final passedArgs =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final String chatID = passedArgs['chatID'];
    final DocumentSnapshot contactDetails = passedArgs['contactDetails'];
    final ContactList _contactList = ContactList.instance;
    return WillPopScope(
      onWillPop: () {
        // Navigator.pop(context);
        // _contactList.saveToDisk();
        _chatBodyOffsetHeight.close();
        _contactList.displayLastMessage(contactDetails.id);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.blueGrey[900]),
          title: Text(
            contactDetails['username'],
            style: TextStyle(color: Colors.blueGrey[900]),
          ),
          centerTitle: true,
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.arrow_back_ios,
          //     color: Colors.blueGrey[900],
          //   ),
          //   onPressed: () {
          //     Navigator.pop(context);
          //     _contactList.saveToDisk();
          //   },
          // ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.call_outlined,
                color: Colors.blueGrey[900],
              ),
              onPressed: () {},
            )
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        body: Stack(
          children: [
            ChatBody(
              chatID: chatID,
              contactDetails: contactDetails,
              chatBodyOffsetHeight: _chatBodyOffsetHeight,
            ),
            ChatInput(
              chatID: chatID,
              contactDetails: contactDetails,
              chatBodyOffsetHeight: _chatBodyOffsetHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBody extends StatelessWidget {
  final String chatID;
  final DocumentSnapshot contactDetails;
  final StreamController<double> chatBodyOffsetHeight;
  const ChatBody({
    Key key,
    this.chatID,
    this.contactDetails,
    this.chatBodyOffsetHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ContactList _contactList = ContactList.instance;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: size.height - 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatID)
                  .collection(chatID)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data.docs.length > 0) {
                  String lastMessage = snapshot.data.docs[0]['content'];
                  String dispMessage = lastMessage.length > 50
                      ? lastMessage.replaceRange(50, lastMessage.length, '...')
                      : lastMessage;
                  dispMessage =
                      snapshot.data.docs[0]['fromID'] == contactDetails.id
                          ? dispMessage
                          : 'YOU: ' + dispMessage;
                  _contactList.updateLastMessage(
                      contactDetails.id, dispMessage);
                }

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot doc = snapshot.data.docs[index];
                    if (doc['fromID'] == contactDetails.id) {
                      // contactMessageBlob
                      return ContactMessageBlob(
                        messageDetails: doc,
                        contactDetails: contactDetails,
                      );
                    } else {
                      // userMessageBlob
                      return UserMessageBlob(messageDetails: doc);
                    }
                  },
                );
              },
            ),
          ),
          StreamBuilder(
              stream: chatBodyOffsetHeight.stream.asBroadcastStream(),
              builder: (context, snapshot) => SizedBox(height: snapshot.data)),
          // KeyboardVisibilityBuilder(
          //   builder: (ctx, isKeyboardVisible) {
          //     return isKeyboardVisible ? SizedBox(height: 45) : SizedBox();
          //   },
          // )
        ],
      ),
    );
  }
}

class ChatInput extends StatefulWidget {
  final String chatID;
  final DocumentSnapshot contactDetails;
  final StreamController<double> chatBodyOffsetHeight;
  const ChatInput({
    Key key,
    this.chatID,
    this.contactDetails,
    this.chatBodyOffsetHeight,
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  // String _enteredMessage = '';
  DocumentSnapshot _userDetails;

  bool _isKeyboardVisible = false;
  bool _isEmojiBoardVisible = false;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((bool isKeyboardVisible) {
      _isKeyboardVisible = isKeyboardVisible;
      _isKeyboardVisible
          ? widget.chatBodyOffsetHeight.add(45.0)
          : widget.chatBodyOffsetHeight.add(0.0);
      if (_isKeyboardVisible && mounted)
        setState(() {
          _isEmojiBoardVisible = false;
        });
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((userDocument) => _userDetails = userDocument);
  }

  void _sendMessage() {
    // FocusScope.of(context).unfocus(); // to close keyboard
    String _enteredMessage = _inputController.text;
    if (_enteredMessage.trim().isEmpty) return;
    _inputController.clear();

    final timeStamp = Timestamp.now();
    final myUserID = FirebaseAuth.instance.currentUser.uid;
    var newMessage = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatID)
        .collection(widget.chatID)
        .doc(timeStamp.millisecondsSinceEpoch.toString());

    newMessage.set({
      'type': 0,
      'fromID': myUserID,
      'toID': widget.contactDetails.id,
      'content': _enteredMessage,
      'timestamp': timeStamp,
    });

    String notificationMessage = _enteredMessage.length > 50
        ? _enteredMessage.replaceRange(50, _enteredMessage.length, '...')
        : _enteredMessage;
    PushNotifications.sendNotification(
        title: _userDetails['username'],
        message: notificationMessage,
        chatID: widget.chatID,
        userID: myUserID,
        notificationToken: widget.contactDetails['notificationtoken']);
  }

  void _toggleEmojiKeyboard() async {
    if (_isKeyboardVisible) {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(Duration(milliseconds: 100));
    } else if (_isEmojiBoardVisible) {
      _focusNode.unfocus();
      _focusNode.requestFocus();
    }
    setState(() {
      _isEmojiBoardVisible = !_isEmojiBoardVisible;
    });
    _isEmojiBoardVisible
        ? widget.chatBodyOffsetHeight.add(270.0)
        : widget.chatBodyOffsetHeight.add(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(_isEmojiBoardVisible
                    ? Icons.keyboard_outlined
                    : Icons.emoji_emotions_outlined),
                onPressed: _toggleEmojiKeyboard,
              ),
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type a message...',
                  ),
                  // onChanged: (value) {
                  //   _enteredMessage = value;
                  // },
                ),
              ),
              IconButton(
                icon: Icon(Icons.attachment_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.send_outlined),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
        SizedBox(
          //   height: max(5, MediaQuery.of(context).viewInsets.bottom),
          height: 5,
        ),
        Offstage(
          child: EmojiPickerWidget(textcontroller: _inputController),
          offstage: !_isEmojiBoardVisible,
        )
        // if (_isEmojiBoardVisible)
        //   EmojiPickerWidget(
        //     textcontroller: _inputController,
        //   ),
      ],
    );
  }
}
