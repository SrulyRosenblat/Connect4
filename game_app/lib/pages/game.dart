import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  List<List<int>> board = List.generate(6, (i) => List.filled(7, 0));
  bool gameOver = false;
  String message = "No game selected";

  final TextEditingController gameIdController = TextEditingController();
  String gameId = "";

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  void updateBoard(boardArray) {
    int index = 0;
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        board[row][col] = boardArray[index];
        index++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connect 4',
          style: TextStyle(fontSize: 48.0),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
                'Connect 4 vertically, horizontally, or diagonally to win'),
            if (gameId != "")
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Games')
                    .doc(gameId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('Error: Game not found');
                  } else {
                    Map<String, dynamic> gameData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List<int> boardArray =
                        List<int>.from(gameData['game_state']);
                    updateBoard(boardArray);
                    message = "${gameData['player_turn']}'s turn";
                    if (gameData['winner'] == "draw") {
                      message = "It's a draw";
                    } else if (gameData['winner'] != null) {
                      message = 'Player ${gameData['winner']} wins!';
                    }
                    return Column(children: [
                      Text(message),
                      ...List.generate(
                        6,
                        (row) => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            7,
                            (col) => GestureDetector(
                              onTap: () {
                                makeMove(col);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.blue,
                                child: Center(
                                  child: Image(
                                      image: AssetImage(
                                    board[row][col] == 0
                                        ? 'assets/Connect_4_empty.png'
                                        : board[row][col] == 1
                                            ? 'assets/Connect_4_orange.png'
                                            : 'assets/Connect_4_blue.png',
                                  )),
                                  // child: Text(
                                  //   board[row][col].toString(),
                                  //   style: TextStyle(
                                  //     color: board[row][col] == 0
                                  //         ? Colors.black
                                  //         : board[row][col] == 1
                                  //             ? Colors.red
                                  //             : Colors.yellow,
                                  //   ),
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]);
                  }
                },
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 200,
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: gameIdController,
                      onChanged: (value) {
                        setState(() {
                          gameId = value;
                        });
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: joinGame,
                  child: const Text('Join Game'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void joinGame() async {
    if (gameId != "") {
      final gameSnapshot =
          await firestore.collection('Games').doc(gameId).get();
      if (gameSnapshot.exists) {
        List<String> playerIds =
            List<String>.from(gameSnapshot.get('player_ids'));
        if (playerIds.length == 1 && playerIds[0] != user!.uid) {
          playerIds.add(user!.uid);
          await gameSnapshot.reference.update({
            'player_ids': playerIds,
          });
        }
      } else {
        board = List.generate(6, (i) => List.filled(7, 0));
        List<int> boardArray = board.expand((row) => row).toList();
        final user = FirebaseAuth.instance.currentUser;
        List<String> playerIds = [user!.uid];
        await firestore.collection('Games').doc(gameId).set({
          'winner': null,
          'game_state': boardArray,
          'player_ids': playerIds,
          'player_turn': user.uid,
        });
      }
    }
  }

  void makeMove(int col) async {
    int currentPlayer = 0;
    final gameSnapshot = await firestore.collection('Games').doc(gameId).get();
    if (gameSnapshot.exists) {
      if (gameSnapshot.get('winner') != null) {
        return;
      }
      if (List<String>.from(gameSnapshot.get('player_ids'))[0].length == 1) {
        return;
      }
      String currentTurn = gameSnapshot.get('player_turn');
      if (currentTurn != user!.uid) {
        return;
      } else {
        if (List<String>.from(gameSnapshot.get('player_ids'))[0] == user!.uid) {
          currentPlayer = 1;
        } else {
          currentPlayer = 2;
        }
      }
    } else {
      return;
    }
    for (int row = 5; row >= 0; row--) {
      if (board[row][col] == 0) {
        setState(() {
          board[row][col] = currentPlayer;
        });
        List<int> boardArray = board.expand((row) => row).toList();
        await firestore.collection('Games').doc(gameId).update({
          'game_state': boardArray,
        });

        if (checkForWin(row, col, currentPlayer)) {
          await firestore.collection('Games').doc(gameId).update({
            'winner': user!.uid,
          });
          gameOver = true;
          //update player ratings
          return;
        } else if (checkForDraw()) {
          await firestore.collection('Games').doc(gameId).update({
            'winner': "draw",
          });
          gameOver = true;
          //update player ratings
          return;
        }

        if (currentPlayer == 1) {
          String player2 = List<String>.from(gameSnapshot.get('player_ids'))[1];
          await firestore.collection('Games').doc(gameId).update({
            'player_turn': player2,
          });
        } else if (currentPlayer == 2) {
          String player1 = List<String>.from(gameSnapshot.get('player_ids'))[0];
          await firestore.collection('Games').doc(gameId).update({
            'player_turn': player1,
          });
        }

        return;
      }
    }
  }

  bool checkForWin(int row, int col, int currentPlayer) {
    // Check horizontally
    for (int c = 0; c < 4; c++) {
      if (board[row][c] == currentPlayer &&
          board[row][c] == board[row][c + 1] &&
          board[row][c + 1] == board[row][c + 2] &&
          board[row][c + 2] == board[row][c + 3]) {
        return true;
      }
    }

    // Check vertically
    for (int r = 0; r < 3; r++) {
      if (board[r][col] == currentPlayer &&
          board[r][col] == board[r + 1][col] &&
          board[r + 1][col] == board[r + 2][col] &&
          board[r + 2][col] == board[r + 3][col]) {
        return true;
      }
    }

    // Check diagonally
    for (int i = 0; i <= 3; i++) {
      if ((row + i < 6 && col + i < 7) &&
          (row + i - 3 >= 0 && col + i - 3 >= 0) &&
          board[row + i][col + i] == currentPlayer &&
          board[row + i][col + i] == board[row + i - 1][col + i - 1] &&
          board[row + i - 1][col + i - 1] == board[row + i - 2][col + i - 2] &&
          board[row + i - 2][col + i - 2] == board[row + i - 3][col + i - 3]) {
        return true;
      }
    }
    for (int i = 0; i <= 3; i++) {
      if ((row + i < 6 && col - i >= 0) &&
          (row + i - 3 >= 0 && col - i + 3 < 7) &&
          board[row + i][col - i] == currentPlayer &&
          board[row + i][col - i] == board[row + i - 1][col - i + 1] &&
          board[row + i - 1][col - i + 1] == board[row + i - 2][col - i + 2] &&
          board[row + i - 2][col - i + 2] == board[row + i - 3][col - i + 3]) {
        return true;
      }
    }

    return false;
  }

  bool checkForDraw() {
    for (int col = 0; col < 7; col++) {
      if (board[0][col] == 0) {
        return false;
      }
    }
    return true;
  }
}
