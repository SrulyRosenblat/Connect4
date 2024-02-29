import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  //when both users connect, push game board and users to firestore, and start allowing moves
  List<List<int>> board = List.generate(6, (i) => List.filled(7, 0));
  int currentPlayer = 1;
  bool gameOver = false;
  String message = "Player 1's turn";

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
            Text(message),
            for (int row = 0; row < 6; row++)
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int col = 0; col < 7; col++)
                      GestureDetector(
                        onTap: () {
                          makeMove(col);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              board[row][col].toString(),
                              style: TextStyle(
                                color: board[row][col] == 0
                                    ? Colors.black
                                    : board[row][col] == 1
                                        ? Colors.red
                                        : Colors.yellow,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(
                height:
                    16),
            ElevatedButton(
              onPressed: resetGame,
              child: const Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }

  void makeMove(int col) {
    //check if correct player is making a move
    if (gameOver) {
      return;
    }
    for (int row = 5; row >= 0; row--) {
      if (board[row][col] == 0) {
        setState(() {
          board[row][col] = currentPlayer;
          //update firestore board as well
        });

        if (checkForWin(row, col)) {
          setState(() {
            message = 'Player $currentPlayer wins!';
            //update both players ratings
          });
          gameOver = true;
          return;
        } else if (checkForDraw()) {
          setState(() {
            message = "It's a draw";
            //update both players ratings
          });
          gameOver = true;
          return;
        }

        if (currentPlayer == 1) {
          currentPlayer = 2;
          setState(() {
            message = "Player 2's turn";
          });
        } else if (currentPlayer == 2) {
          currentPlayer = 1;
          setState(() {
            message = "Player 1's turn";
          });
        }
        return;
      }
    }
  }

  bool checkForWin(int row, int col) {
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

  void resetGame() {
    //will need to await both players
    gameOver = false;
    setState(() {
      board = List.generate(6, (i) => List.filled(7, 0));
      currentPlayer = 1;
      message = "Player 1's turn";
    });
  }
}
