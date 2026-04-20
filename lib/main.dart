import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';

import 'models/enums.dart';
import 'models/player_state.dart';
import 'screens/main_menu.dart';
import 'screens/jobs/apothecary_panel.dart';
import 'screens/jobs/artisen_trade_panel.dart';
import 'screens/jobs/blacksmith_panel.dart';
import 'screens/jobs/reever_panel.dart';
import 'screens/inventory_view.dart';
import 'game/artisan_game.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => PlayerState())],
      child: const ArtisanApp(),
    ),
  );
}

class ArtisanApp extends StatelessWidget {
  const ArtisanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerState>(
      builder: (context, state, child) {
        return MaterialApp(
          title: 'Artisans of Fortuna',
          themeMode: state.currentTheme,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.brown,
            scaffoldBackgroundColor: Colors.grey[200],
            colorScheme: const ColorScheme.light(
              primary: Colors.brown,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.brown,
            scaffoldBackgroundColor: Colors.black,
            colorScheme: ColorScheme.dark(
              primary: Colors.amber,
              surface: Colors.blueGrey[900]!,
              onSurface: Colors.white,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const MainGate(),
        );
      },
    );
  }
}

class MainGate extends StatefulWidget {
  const MainGate({Key? key}) : super(key: key);

  @override
  State<MainGate> createState() => _MainGateState();
}

class _MainGateState extends State<MainGate> {
  bool _isPlaying = false;
  ArtisanGame? _game;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _game = ArtisanGame(playerState: context.read<PlayerState>());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return MainMenuScreen(onStartGame: _startGame);
    }

    return Scaffold(
      body: Stack(
        children: [
          // The underlying Flame 2D game map
          GameWidget(game: _game!),

          // UI overlays on top of the game world
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<PlayerState>(
                    builder: (context, state, child) {
                      return IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.black54,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Job: ${state.currentJob.name.toUpperCase()}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.brightness_6,
                                          color: Colors.amberAccent,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => state.toggleTheme(),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            InventoryView.show(context),
                                        icon: const Icon(
                                          Icons.backpack,
                                          color: Colors.amberAccent,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Inventory',
                                          style: TextStyle(
                                            color: Colors.amberAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Hunger: ${state.hunger}/${state.maxHunger}",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Wealth: ${state.formattedActiveWallet}",
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),

                  // Active Job Workspace Panel
                  Expanded(
                    child: Consumer<PlayerState>(
                      builder: (context, state, child) {
                        if (state.isShopOpen) {
                          return const MerchantPanel();
                        }

                        if (state.currentJob == JobType.apothecary) {
                          return const ApothecaryPanel();
                        }

                        if (state.currentJob.name.startsWith('blacksmith')) {
                          return const BlacksmithPanel();
                        }

                        if (state.currentJob == JobType.reever) {
                          return const ReeverPanel();
                        }

                        // Fallback for unimplemented jobs
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.black54,
                          child: Text(
                            'Workspace: ${state.currentJob.name.toUpperCase()}\n(Under Construction)',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job switching UI
                  Consumer<PlayerState>(
                    builder: (context, state, child) {
                      return Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 6,
                        runSpacing: 4,
                        children: JobType.values.map((job) {
                          final isSelected = state.currentJob == job;
                          final isUnlocked = state.isJobUnlocked(job);

                          if (!isUnlocked) {
                            return ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[900],
                              ),
                              child: Text(
                                'LOCKED',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white24,
                                ),
                              ),
                            );
                          }

                          return ElevatedButton(
                            onPressed: isSelected
                                ? null
                                : () => state.switchJob(job),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.grey
                                  : Colors.blueGrey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: Text(
                              job.name.split('_').last,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
