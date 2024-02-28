import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const Row(
        children: [
          Spacer(
            flex: 1,
          ),
          Column(
            children: [
              Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 150,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "name",
                            textAlign: TextAlign.start,
                          ),
                          Text("lorem ipsdfas fdsfasdfdsaf dsad f"),
                        ]),
                  ),
                ),
              )
            ],
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
