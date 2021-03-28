import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'contact_list.g.dart';

@HiveType(typeId: 0)
class ContactInfo extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String avatar;
  @HiveField(3)
  String lastMessage;
  @HiveField(4)
  bool isUnreadMessage;
  @HiveField(5)
  int lastMesTimestamp;

  ContactInfo.fromSnapshot(DocumentSnapshot userDocument) {
    if (userDocument.exists) {
      id = userDocument.id;
      name = userDocument.data().containsKey('username')
          ? userDocument['username']
          : '<bad_schema_rbk>';
      avatar = userDocument.data().containsKey('imageURL')
          ? userDocument['imageURL']
          : '<bad_schema_rbk>';
    }
    lastMessage = '<start chatting>';
    isUnreadMessage = false;
    lastMesTimestamp = 0;
    Hive.openBox<ContactInfo>("contact_list")
        .then((box) => box.put(this.id, this));
  }

  // default constructor with no parameters (for hive typeAdapter)
  ContactInfo();

  // ContactInfo.fromJson(String jsonString) {
  //   Map<String, dynamic> data = json.decode(jsonString);
  //   id = data['id'];
  //   name = data['name'];
  //   avatar = data['avatar'];
  //   lastMessage = data['lastMessage'];
  //   isUnreadMessage = data['isUnreadMessage'];
  // }

  void update(DocumentSnapshot userDocument) {
    if (userDocument.exists) {
      id = userDocument.id;
      name = userDocument.data().containsKey('username')
          ? userDocument['username']
          : name;
      avatar = userDocument.data().containsKey('imageURL')
          ? userDocument['imageURL']
          : avatar;
      save();
    }
  }

  // String toJsonString() {
  //   return json.encode({
  //     'id': id,
  //     'name': name,
  //     'avatar': avatar,
  //     'lastMessage': lastMessage,
  //     'isUnreadMessage': isUnreadMessage
  //   });
  // }
}

class ContactList extends ChangeNotifier {
  List<ContactInfo> _contacts = [];

  // private constuctor. for making class as singleton
  ContactList._contactList() {
    loadFromDisk();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null)
        FirebaseFirestore.instance
            .collection('users')
            .snapshots()
            .listen((userSnapshot) {
          final userdocuments = userSnapshot.docChanges;
          final currentUserID = FirebaseAuth.instance.currentUser.uid;
          for (int i = 0; i < userdocuments.length; i++) {
            if (userdocuments[i].doc.id == currentUserID) continue;
            int listIndex = _contacts
                .indexWhere((element) => element.id == userdocuments[i].doc.id);
            if (listIndex == -1)
              _contacts.add(ContactInfo.fromSnapshot(userdocuments[i].doc));
            else
              _contacts[listIndex].update(userdocuments[i].doc);
          }
          notifyListeners();
          // saveToDisk();
        });
    });
  }

  static final ContactList instance = ContactList._contactList();

  List<ContactInfo> get contactList {
    return [..._contacts];
  }

  Future<void> loadFromDisk() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (prefs.containsKey('contact_list')) {
    //   List<String> contactList = prefs.getStringList('contact_list');
    //   contactList.forEach((contact) {
    //     _contacts.add(ContactInfo.fromJson(contact));
    //   });
    // }
    await Hive.initFlutter();
    Hive.registerAdapter(ContactInfoAdapter());
    var box = await Hive.openBox<ContactInfo>("contact_list");
    if (box.length > 0) {
      box.values.forEach((contact) {
        _contacts.add(contact);
      });
    }
    _contacts.sort((a, b) => b.lastMesTimestamp.compareTo(a.lastMesTimestamp));
  }

  // void saveToDisk() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> data = [];

  //   _contacts.forEach((element) {
  //     data.add(element.toJsonString());
  //   });
  //   prefs.setStringList('contact_list', data);
  // }

  void updateLastMessage(String contactID, String message) {
    int index = _contacts.indexWhere((element) => element.id == contactID);
    ContactInfo contactinfo = _contacts[index];
    if (contactinfo.lastMessage == message) return;
    contactinfo.lastMessage = message;
    contactinfo.lastMesTimestamp = DateTime.now().millisecondsSinceEpoch;
    _contacts.removeAt(index);
    _contacts.insert(0, contactinfo);
    // notifyListeners();
  }

  void displayLastMessage(String contactID) {
    int index = _contacts.indexWhere((element) => element.id == contactID);
    ContactInfo contactinfo = _contacts[index];
    contactinfo.save();
    notifyListeners();
  }

  void updateUnreadMessage(String contactID, bool isUnread) {
    int index = _contacts.indexWhere((element) => element.id == contactID);
    ContactInfo contactinfo = _contacts[index];
    contactinfo.isUnreadMessage = isUnread;
    _contacts[index] = contactinfo;
    contactinfo.save();
  }
}
