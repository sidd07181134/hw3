import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Card Matching Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final dynamic title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List to store card images
  List<String> cardImages = [
    '🐱', '🐶', '🦊', '🐰', '🐼', '🐨', '🐸', '🦄',
    '🐱', '🐶', '🦊', '🐰', '🐼', '🐨', '🐸', '🦄'
  ];
  // List to track flipped cards
  List<bool> flipped = [];
  List<int> selectedCards = [];
  int matches = 0;
  int score = 0;
  Timer? timer;
  int timeElapsed = 0;

  @override
  void initState() {
    super.initState();
    cardImages.shuffle();
    flipped = List<bool>.filled(cardImages.length, false);
    startTimer();
  }

  // Start the timer for the game
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeElapsed++;
      });
    });
  }

  // Flip a card and check for a match
  void flipCard(int index) {
    if (selectedCards.length < 2 && !flipped[index]) {
      setState(() {
        flipped[index] = true;
        selectedCards.add(index);
      });

      if (selectedCards.length == 2) {
        if (cardImages[selectedCards[0]] == cardImages[selectedCards[1]]) {
          score += 10;
          matches++;
          if (matches == cardImages.length ~/ 2) {
            timer?.cancel();
            showWinDialog();
          }
          selectedCards.clear();
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              flipped[selectedCards[0]] = false;
              flipped[selectedCards[1]] = false;
              selectedCards.clear();
              score -= 2;
            });
          });
        }
      }
    }
  }

  // Display winning dialog
  void showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('You Won!'),
        content: Text('You finished in $timeElapsed seconds with a score of $score.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  // Reset the game
  void resetGame() {
    setState(() {
      cardImages.shuffle();
      flipped = List<bool>.filled(cardImages.length, false);
      selectedCards.clear();
      matches = 0;
      score = 0;
      timeElapsed = 0;
      startTimer();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Time: $timeElapsed seconds'),
                Text('Score: $score'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: cardImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => flipCard(index),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return RotationTransition(
                        turns: child.key == const ValueKey('front')
                            ? Tween<double>(begin: 1, end: 0.5).animate(animation)
                            : Tween<double>(begin: 0.5, end: 1).animate(animation),
                        child: child,
                      );
                    },
                    child: flipped[index]
                        ? Card(
                            key: const ValueKey('front'),
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                cardImages[index],
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          )
                        : Card(
                            key: const ValueKey('back'),
                            color: Colors.blue,
                            child: const Center(
                              child: Text(
                                '❓',
                                style: TextStyle(fontSize: 40, color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: resetGame,
        tooltip: 'Reset Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
