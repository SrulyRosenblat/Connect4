import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_app/pages/Profile.dart';
import 'package:game_app/pages/SignIn.dart';
import 'package:game_app/pages/game.dart';
import 'package:game_app/pages/chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_app/pages/match_making.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userDoc;

  changeDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  setUpDoc(id) async {
    Map<String, dynamic>? doc =
        (await FirebaseFirestore.instance.collection('users').doc(id).get())
            .data();
    setState(() {
      _userDoc = doc;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, userSnapshot) {
          if (userSnapshot.data == null) {
            return const SignIn();
          }
          var currentUser = userSnapshot.data;
          Stream<DocumentSnapshot> userDocumentStream =
              _firestore.collection('users').doc(currentUser!.uid).snapshots();
          return StreamBuilder<DocumentSnapshot>(
            stream: userDocumentStream,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                Map<String, dynamic>? userDoc =
                    snapshot.data?.data() as Map<String, dynamic>?;
                print("updating");
                final Widget page;
                switch (_selectedIndex) {
                  case 0:
                    if (userDoc == null) {
                      page = const CircularProgressIndicator();
                    } else if (userDoc['currentGameID'] != null) {
                      page = GamePage(gameId: userDoc['currentGameID']);
                    } else {
                      page = MatchMaking(
                        userDoc: userDoc,
                      );
                    }
                  case 1:
                    page = const ChatPage();
                  case 2:
                    page = Profile();
                  default:
                    return const Text("ERROR");
                }
                return Scaffold(
                    body: Row(
                  children: [
                    NavigationRail(
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
                    Expanded(child: page)
                  ],
                ));
              }
            },
          );

          // if (!snapshot.hasData) {
          //   return const CircularProgressIndicator();
          // } else {
          //   DocumentSnapshot userDoc = snapshot.data!;
          //   bool inGame = userDoc['inGame'];
          //   final Widget page;
          //   switch (_selectedIndex) {
          //     case 0:
          //       if (inGame) {
          //         page = const GamePage();
          //       } else {
          //         page = const MatchMaking();
          //       }
          //     case 1:
          //       page = const ChatPage();
          //     case 2:
          //       page = Profile();
          //     default:
          //       return const Text("ERROR");
          //   }
          //   return Scaffold(
          //       body: Row(
          //     children: [
          //       NavigationRail(
          //         destinations: const [
          //           NavigationRailDestination(
          //             icon: Icon(Icons.games_outlined),
          //             selectedIcon: Icon(Icons.games),
          //             label: Text('Game'),
          //           ),
          //           NavigationRailDestination(
          //             icon: Icon(Icons.chat_bubble_outline),
          //             selectedIcon: Icon(Icons.chat_bubble),
          //             label: Text('Chat'),
          //           ),
          //           NavigationRailDestination(
          //             icon: Icon(Icons.person_outline),
          //             selectedIcon: Icon(Icons.person),
          //             label: Text('profile'),
          //           ),
          //         ],
          //         selectedIndex: _selectedIndex,
          //         useIndicator: true,
          //         elevation: 4,
          //         onDestinationSelected: changeDestination,
          //       ),
          //       Expanded(child: page)
          //     ],
          //   ));
          // }
        });

    // switch (_selectedIndex) {
    //   case 0:
    //     if (_userDoc == null) {
    //       selectedPage = Placeholder();
    //       break;
    //     }
    //     bool inGame = _userDoc!['inGame'];
    //     selectedPage = inGame ? const GamePage() : const MatchMaking();
    //     break;
    //   case 1:
    //     selectedPage = const ChatPage();
    //     break;
    //   case 2:
    //     selectedPage = StreamBuilder<User?>(
    //       stream: FirebaseAuth.instance.authStateChanges(),
    //       builder: (context, snapshot) {
    //         // User is not signed in
    //         if (!snapshot.hasData) {
    //           return SignIn();
    //         }

    //         // Render your application if authenticated
    //         return Profile();
    //       },
    //     );
    //     break;
    //   default:
    //     selectedPage = const Text("ERROR");
    // }
    // return Scaffold(
    //     body: Row(
    //   children: [
    //     NavigationRail(
    //       destinations: const [
    //         NavigationRailDestination(
    //           icon: Icon(Icons.games_outlined),
    //           selectedIcon: Icon(Icons.games),
    //           label: Text('Game'),
    //         ),
    //         NavigationRailDestination(
    //           icon: Icon(Icons.chat_bubble_outline),
    //           selectedIcon: Icon(Icons.chat_bubble),
    //           label: Text('Chat'),
    //         ),
    //         NavigationRailDestination(
    //           icon: Icon(Icons.person_outline),
    //           selectedIcon: Icon(Icons.person),
    //           label: Text('profile'),
    //         ),
    //       ],
    //       selectedIndex: _selectedIndex,
    //       useIndicator: true,
    //       elevation: 4,
    //       onDestinationSelected: changeDestination,
    //     ),
    //     Expanded(child: selectedPage)
    //   ],
    // ));
  }
}
