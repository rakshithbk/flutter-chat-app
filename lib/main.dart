import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/contact_list.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/push_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotifications.initialize();
  runApp(MyApp());
}
// https://search.muz.li/NDdkNDdkYmJj?utm_source=muz.li-insp&utm_medium=article&utm_campaign=%2Finspiration%2Fchat-ui%2F

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MultiProvider(
        providers: [ChangeNotifierProvider.value(value: ContactList.instance)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat memes',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            backgroundColor: Colors.white,
            accentColor: Colors.blueGrey[900],
            iconTheme: Theme.of(context)
                .iconTheme
                .copyWith(color: Colors.blueGrey[900]),
            fontFamily: 'VarelaRound',
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData) {
                return HomeScreen();
              }
              return AuthScreen();
            },
          ),
          navigatorKey: navigatorKey,
          routes: {
            ChatScreen.routeName: (context) => ChatScreen(),
            SettingScreen.routeName: (context) => SettingScreen(),
          },
        ),
      ),
    );
  }
}
