import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_game/enum/player_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'decoration/door.dart';
import 'decoration/key.dart';
import 'decoration/potion_life.dart';
import 'decoration/spikes.dart';
import 'decoration/torch.dart';
import 'enemies/boss.dart';
import 'enemies/goblin.dart';
import 'enemies/imp.dart';
import 'enemies/mini_boss.dart';
import 'interface/player_interface.dart';
import 'main.dart';
import 'models/player.dart';
import 'npc/kid.dart';
import 'npc/wizard_npc.dart';
import 'utils/dialogs.dart';
import 'utils/sounds.dart';

class Game extends StatefulWidget {
  static bool useJoystick = true;
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> implements GameListener {
  bool showGameOver = false;

  late GameController _controller;

  @override
  void initState() {
    _controller = GameController()..addListener(this);
    Sounds.playBackgroundSound();
    super.initState();
  }

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery.of(context).size;
    tileSize = max(sizeScreen.height, sizeScreen.width) / 15;

    var joystick = Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: 100,
        isFixed: false,
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          sprite: Sprite.load('joystick_atack.png'),
          spritePressed: Sprite.load('joystick_atack_selected.png'),
          size: 80,
          margin: EdgeInsets.only(bottom: 50, right: 50),
        ),
        JoystickAction(
          actionId: 1,
          sprite: Sprite.load('joystick_atack_range.png'),
          spritePressed: Sprite.load('joystick_atack_range_selected.png'),
          size: 50,
          margin: EdgeInsets.only(bottom: 50, right: 160),
        )
      ],
    );
    if (!Game.useJoystick) {
      joystick = Joystick(
        keyboardConfig: KeyboardConfig(
          keyboardDirectionalType: KeyboardDirectionalType.wasdAndArrows,
          acceptedKeys: [
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.keyZ,
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: BonfireWidget(
        gameController: _controller,
        joystick: joystick,
        player: PlayerModel(
          Vector2(2 * tileSize, 3 * tileSize),
          playerType: PlayerType.knight,
        ),
        map: WorldMapByTiled(
          'tiled/map.json',
          forceTileSize: Vector2(tileSize, tileSize),
          objectsBuilder: {
            'door': (p) => Door(p.position, p.size),
            'torch': (p) => Torch(p.position),
            'potion': (p) => PotionLife(p.position, 30),
            'wizard': (p) => WizardNPC(p.position),
            'spikes': (p) => Spikes(p.position),
            'key': (p) => DoorKey(p.position),
            'kid': (p) => Kid(p.position),
            'boss': (p) => Boss(p.position),
            'goblin': (p) => Goblin(p.position),
            'imp': (p) => Imp(p.position),
            'mini_boss': (p) => MiniBoss(p.position),
            'torch_empty': (p) => Torch(p.position, empty: true),
          },
        ),
        interface: PlayerInterface(),
        lightingColorGame: Colors.black.withOpacity(0.6),
        background: BackgroundColorGame(Colors.grey[900]!),
        progress: Container(
          color: Colors.black,
          child: Center(
            child: Text(
              "Loading...",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Normal',
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDialogGameOver() {
    setState(() {
      showGameOver = true;
    });
    Dialogs.showGameOver(
      context,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Game()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  @override
  void changeCountLiveEnemies(int count) {}

  @override
  void updateGame() {
    if (_controller.player != null && _controller.player?.isDead == true) {
      if (!showGameOver) {
        showGameOver = true;
        _showDialogGameOver();
      }
    }
  }
}
