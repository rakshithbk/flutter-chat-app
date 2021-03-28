import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _inputController = TextEditingController();
  String _enteredName = '';

  DocumentSnapshot userProfile;

  final _imagePicker = ImagePicker();
  bool _isImageUpdated = false;
  PickedFile _image;

  Future<DocumentSnapshot> _getUserProfile() async {
    final userUID = FirebaseAuth.instance.currentUser.uid;
    final userProfileFuture =
        await FirebaseFirestore.instance.collection('users').doc(userUID).get();
    return userProfileFuture;
  }

  void _pickImage(ImageSource source) async {
    _image = await _imagePicker.getImage(
      source: source,
      imageQuality: 50,
      maxWidth: 300,
    );
    setState(() {
      _isImageUpdated = true;
    });
  }

  Future<void> _updateUserProfile(
      BuildContext context, DocumentSnapshot userDoc) async {
    final userDetails = FirebaseAuth.instance.currentUser;
    if (_isImageUpdated) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${userDetails.uid}.jpg');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Updating'),
            content: CircularProgressIndicator(),
          );
        },
      );
      await ref.putFile(File(_image.path));

      final imageURL = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDetails.uid)
          .update({'imageURL': imageURL});

      Navigator.of(context).pop(); // pop AlertDialog
    }
    if (_enteredName.trim() != '' && userDoc['username'] != _enteredName) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDetails.uid)
          .update({'username': _enteredName});
    }
    Navigator.of(context).pop(); // close settings screen
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  ImageProvider _displayImage(DocumentSnapshot userDetails) {
    if (_isImageUpdated)
      return FileImage(File(_image.path));
    else if (userDetails['imageURL'] != '')
      return CachedNetworkImageProvider(userDetails['imageURL']);
    else
      return AssetImage('assets/comic.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: FutureBuilder(
        future: _getUserProfile(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            _inputController..text = userSnapshot.data['username'];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: _displayImage(userSnapshot.data),
                        child: TextButton.icon(
                          icon: Icon(Icons.image_outlined),
                          label: Text('Add/change'),
                          onPressed: () {
                            _showPicker(context);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _inputController,
                      maxLength: 50,
                      style: TextStyle(fontSize: 25),
                      decoration: InputDecoration(
                        labelText: 'DisplayName',
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: 'Enter new name',
                        hintStyle: TextStyle(fontSize: 18),
                        icon: Icon(Icons.face_outlined),
                      ),
                      onChanged: (value) => _enteredName = value,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Update'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                        ),
                        onPressed: () =>
                            _updateUserProfile(context, userSnapshot.data),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
