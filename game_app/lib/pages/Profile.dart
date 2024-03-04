import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _usernameController = TextEditingController();
  // Default values
  String _username = 'Anonymous'; 
  int _score = 0; 

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          _username = docSnapshot.data()?['name'] ?? 'Anonymous';
          _score = docSnapshot.data()?['score'] ?? 0;
        });
      }
    }
  }

  Future<void> _updateUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _usernameController.text,
      }, SetOptions(merge: true));
      setState(() {
        _username = _usernameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username updated to ${_usernameController.text}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _usernameController.text = _username; 

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Username: $_username", textAlign: TextAlign.center),
          SizedBox(height: 20),
          Text("Score: $_score", textAlign: TextAlign.center), 
          SizedBox(height: 20),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Set a new username'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateUsername, 
            child: const Text("Update Username"),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}
