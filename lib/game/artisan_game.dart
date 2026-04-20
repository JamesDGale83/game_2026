import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/player_state.dart';

class ArtisanGame extends FlameGame {
  // A simple timer component to represent the passing of time
  late Timer timeTicker;
  int gameDays = 0;
  final PlayerState playerState;

  ArtisanGame({required this.playerState});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Set a basic background color representing the "grass/earth"
    add(BackgroundComponent());

    // Tick every 5 seconds as one "game cycle/day"
    timeTicker = Timer(5.0, onTick: _onDayPass, repeat: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeTicker.update(dt);
  }

  void _onDayPass() {
    gameDays++;
    playerState.processTick();
  }
}

class BackgroundComponent extends PositionComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = gameRef.size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw a very simple green base for now
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xFF2E7D32), // Dark green
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
