import 'package:flutter/material.dart';
import 'package:silk_innovation_swativerma/data.dart';
import 'package:silk_innovation_swativerma/model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Game(),
    );
  }
}

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      points = 0;
      pairs = getPairs();
      pairs.shuffle();
      question = pairs;
      selected = true;

      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          question = getQuestions();
          selected = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: <Widget>[
            Text('$points/600'),
            const Text('Point'),
            const SizedBox(
              height: 20,
            ),
            GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 0.0,
                maxCrossAxisExtent: 100,
              ),
              children: List.generate(pairs.length, (index) {
                return Tile(
                  imageAssetPath: question[index].getImageAssetPath(),
                  parent: this,
                  tileIndex: index,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void checkGameOver() {
    if (points >= 600) {
      print("Game Over");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Game Over"),
          content: Text("You have reached 600 points!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startGame(); // Restart the game
              },
              child: Text("Restart"),
            ),
          ],
        ),
      );
    }
  }
}

class Tile extends StatefulWidget {
  String? imageAssetPath;
  int? tileIndex;
  _GameState? parent;
  Tile({this.imageAssetPath, this.parent, this.tileIndex});

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    TileModel tileModel = pairs[widget.tileIndex!];
    bool isSelected = tileModel.getIsSelected() ?? false;
    return GestureDetector(
      onTap: () {
        if (!isSelected && points < 800) {
          if (selectedTileIndex != null && selectedImageAssetPath != null) {
            String currentImageAssetPath =
                tileModel.getImageAssetPath() ?? "";
            if (selectedImageAssetPath == currentImageAssetPath) {
              print("correct");
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  points += 100;
                  widget.parent!.checkGameOver();
                });
                widget.parent!.setState(() {
                  pairs[widget.tileIndex!]
                      .setImageAssetPath("assets/correct.png");
                  pairs[selectedTileIndex!]
                      .setImageAssetPath("assets/correct.png");
                });
                selectedTileIndex = null;
                selectedImageAssetPath = null;
              });
            } else {
              print("incorrect");
              Future.delayed(const Duration(seconds: 2), () {
                widget.parent!.setState(() {
                  pairs[widget.tileIndex!].setIsSelected(false);
                  pairs[selectedTileIndex!].setIsSelected(false);
                });
                selectedTileIndex = null;
                selectedImageAssetPath = null;
              });
            }
          } else {
            selectedTileIndex = widget.tileIndex!;
            selectedImageAssetPath = tileModel.getImageAssetPath();
          }
          setState(() {
            tileModel.setIsSelected(true);
          });
          print("clicked");
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: tileModel.getImageAssetPath() != ""
            ? Image.asset(
                isSelected
                    ? tileModel.getImageAssetPath()!
                    : widget.imageAssetPath ?? "assets/default.png",
              )
            : Image.asset(widget.imageAssetPath ?? "assets/default.png"),
      ),
    );
  }
}
