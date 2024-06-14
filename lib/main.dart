import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 20;
  static const int columns = 20;
  static const int squareSize = 20;
  final randomGen = Random();

  List<List<int>> snake = [[10, 10]];
  String direction = 'up';
  List<int> food = [0, 0];
  bool isPlaying = false;
  int score = 0;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    createFood();
  }

  void startGame() {
    const duration = Duration(milliseconds: 200);
    setState(() {
      snake = [
        [(rows / 2).floor(), (columns / 2).floor()]
      ];
      direction = 'up';
      createFood();
      isPlaying = true;
      score = 0;
    });

    Timer.periodic(duration, (Timer timer) {
      updateGame();
      if (!isPlaying) {
        timer.cancel();
        showGameOverScreen();
      }
    });
  }

  void updateGame() {
    setState(() {
      var newHead = [snake.first[0], snake.first[1]];

      switch (direction) {
        case 'up':
          newHead[0] -= 1;
          break;
        case 'down':
          newHead[0] += 1;
          break;
        case 'left':
          newHead[1] -= 1;
          break;
        case 'right':
          newHead[1] += 1;
          break;
      }

      if (newHead[0] < 0) {
        newHead[0] = rows - 1;
      } else if (newHead[0] >= rows) {
        newHead[0] = 0;
      }

      if (newHead[1] < 0) {
        newHead[1] = columns - 1;
      } else if (newHead[1] >= columns) {
        newHead[1] = 0;
      }

      if (newHead[0] == food[0] && newHead[1] == food[1]) {
        score++;
        createFood();
      } else {
        snake.removeLast();
      }

      if (snake.skip(1).any((part) => part[0] == newHead[0] && part[1] == newHead[1])) {
        isPlaying = false;
      }

      snake.insert(0, newHead);
    });
  }

  void createFood() {
    do {
      food = [
        randomGen.nextInt(rows),
        randomGen.nextInt(columns)
      ];
    } while (snake.any((part) => part[0] == food[0] && part[1] == food[1]));
  }

  void changeDirection(String newDirection) {
    if (direction == 'up' && newDirection == 'down' ||
        direction == 'down' && newDirection == 'up' ||
        direction == 'left' && newDirection == 'right' ||
        direction == 'right' && newDirection == 'left') {
      return;
    }
    setState(() {
      direction = newDirection;
    });
  }

  void showGameOverScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyLabel) {
        case 'Arrow Up':
          changeDirection('up');
          break;
        case 'Arrow Down':
          changeDirection('down');
          break;
        case 'Arrow Left':
          changeDirection('left');
          break;
        case 'Arrow Right':
          changeDirection('right');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.primaryDelta! > 0) {
                    changeDirection('right');
                  } else if (details.primaryDelta! < 0) {
                    changeDirection('left');
                  }
                },
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 0) {
                    changeDirection('down');
                  } else if (details.primaryDelta! < 0) {
                    changeDirection('up');
                  }
                },
                child: AspectRatio(
                  aspectRatio: rows / (columns),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                      ),
                      itemCount: rows * columns,
                      itemBuilder: (BuildContext context, int index) {
                        var color = Colors.grey[800];
                        var x = index % columns;
                        var y = (index / columns).floor();
                        if (snake.any((part) => part[0] == y && part[1] == x)) {
                          if (snake.first[0] == y && snake.first[1] == x) {
                            return Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    margin: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    margin: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            color = Colors.green[400];
                          }
                        } else if (food[0] == y && food[1] == x) {
                          return Center(
                            child: Icon(
                              Icons.apple,
                              color: Colors.red[400],
                              size: squareSize.toDouble(),
                            ),
                          );
                        }
                        return Container(
                          margin: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: isPlaying ? null : startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: Text('Start Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
