import 'package:flutter/material.dart';
import 'package:silk_innovation_swativerma/data.dart';
import 'package:silk_innovation_swativerma/model.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                      mainAxisSpacing: 0.0, maxCrossAxisExtent: 100),
                  children: List.generate(pairs.length, (index) {
                    return Tile(
                      imageAssetPath: question[index].getImageAssetPath(),
                      parent: this,
                      tileIndex: index,
                    );
                  }))
            ],
          )),
    );
  }

  void checkGameOver() {
    if (points >= 600) {
      // Game over condition
      print("Game Over");
      // Navigate to game over screen or perform any other actions
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
                // Correct match logic remains the same
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
                  // Clear the selected tile information after correct match
                  selectedTileIndex = null;
                  selectedImageAssetPath = null;
                });
              } else {
                // Incorrect match logic
                print("incorrect");
                Future.delayed(const Duration(seconds: 2), () {
                  // Flip back only the incorrectly matched tiles
                  widget.parent!.setState(() {
                    pairs[widget.tileIndex!].setIsSelected(false);
                    pairs[selectedTileIndex!].setIsSelected(false);
                  });
                  // Clear the selected tile information after incorrect match
                  selectedTileIndex = null;
                  selectedImageAssetPath = null;
                });
              }
            } else {
              // Set the selected tile information
              selectedTileIndex = widget.tileIndex!;
              selectedImageAssetPath = tileModel.getImageAssetPath();
            }
            // Toggle the selected state of the current tile
            setState(() {
              tileModel.setIsSelected(true);
            });
            print("clicked");
          }
        },
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: tileModel.getImageAssetPath() !=
                  "" // Check if imageAssetPath is not empty
              ? Image.asset(
                  isSelected
                      ? tileModel
                          .getImageAssetPath()! // Use tile's imageAssetPath if selected
                      : widget.imageAssetPath ??
                          "assets/default.png", // Use widget's imageAssetPath or fallback image if not selected
                )
              : Image.asset(widget.imageAssetPath ?? "assets/default.png"),
        ));
  }
}
