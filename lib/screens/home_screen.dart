import 'package:flutter/material.dart';

import '../widgets/contact_list_widget.dart';
import '../widgets/side_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: SideMenuDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          "Messaging",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded),
            onPressed: () {},
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            color: Colors.blueGrey[900],
          ),
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Colors.white,
            ),
            child: ContactListWidget(),
          ),
        ],
      ),
    );
  }
}
