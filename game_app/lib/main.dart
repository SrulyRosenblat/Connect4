import 'package:flutter/material.dart';
import 'package:game_app/pages/Profile.dart';
import 'package:game_app/pages/SignIn.dart';
import 'package:game_app/pages/chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user != null) {
    checkOrCreateUserData(user); 
  }
  });
  runApp(const MyApp());
}

Future<void> checkOrCreateUserData(User user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await userRef.get();
  if (!doc.exists) {
    await userRef.set({
      'name': user.displayName ?? 'Anonymous', 
      'score': 0,
    });
    print('User data created for ${user.uid}');
  } else {
    print('User data exists for ${user.uid}');
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  changeDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // show page
    Widget selectedPage;
    switch (_selectedIndex) {
      case 0:
        selectedPage = const Placeholder();
        break;
      case 1:
        selectedPage = const ChatPage();
        break;
      case 2:
        selectedPage = StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // if signed in
            if (!snapshot.hasData) {
              return SignIn();
            }
            // else...
            return Profile();
          },
        );
        break;
      default:
        selectedPage = const Text("ERROR");
    }
    return Scaffold(
        body: Row(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.white10, Colors.black],
          )),
          child: NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.games_outlined),
                selectedIcon: Icon(Icons.games),
                label: Text('Game'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('profile'),
              ),
            ],
            selectedIndex: _selectedIndex,
            useIndicator: true,
            elevation: 4,
            onDestinationSelected: changeDestination,
          ),
        ),
        Expanded(child: selectedPage)
      ],
    ));
  }
}
