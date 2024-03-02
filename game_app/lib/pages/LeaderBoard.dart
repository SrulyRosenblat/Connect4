import 'package:flutter/material.dart';

final List<Map<String, dynamic>> leaderboardData = [
  {'name': 'test', 'score': 150},
  {'name': 'test2', 'score': 200},
  {'name': 'test3', 'score': 130},
  {'name': 'test4', 'score': 45},
  {'name': 'test5', 'score': 300}
];

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    leaderboardData.sort((a, b) => b['score'].compareTo(a['score']));

    final topThree = leaderboardData.sublist(0, 3);
    final rest = leaderboardData.sublist(3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Container(
            //width: 600,
            child: Column(
              children: [
                // Top three players layout
                SizedBox(
                  height: 200, 
                  width: 500,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // First player
                      _buildPlayerCircle(topThree, 0, '1', Colors.amber),
                      // Second player
                      Positioned(
                        left: 100,
                        bottom: 0,
                        child: _buildPlayerCircle(topThree, 1, '2', Colors.blue),
                      ),
                      // Third player
                      Positioned(
                        right: 100,
                        bottom: 0,
                        child: _buildPlayerCircle(topThree, 2, '3', Colors.blue),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Remaining players
                Expanded(
                  child: ListView.separated(
                    itemCount: rest.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 4}'),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        title: Text(rest[index]['name']),
                        trailing: Text('${rest[index]['score']} points'),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCircle(List<Map<String, dynamic>> players, int index, String rank, Color color) {
    if (index >= players.length) {
      return Container(); 
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rank, style: TextStyle(fontSize: 24, color: Colors.white)),
            Text(players[index]['name'], style: TextStyle(color: Colors.white)),
            Text('${players[index]['score']} points', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}