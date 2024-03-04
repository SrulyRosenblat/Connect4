import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchMaking extends StatefulWidget {
  final userDoc;

  const MatchMaking({super.key, this.userDoc});

  @override
  State<MatchMaking> createState() => _MatchMakingState();
}

class _MatchMakingState extends State<MatchMaking> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Spacer(),
            Text(widget.userDoc['waiting'] ?? false
                ? "Waiting for match"
                : "Not waiting for match"),
            FilledButton(
              onPressed: () async {
                if (widget.userDoc['waiting'] ?? false) {
                  return;
                }
                await firestore
                    .collection('users')
                    .doc(widget.userDoc['uid'])
                    .update({
                  'waiting': true,
                });
              },
              child: Text("Find Match"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
