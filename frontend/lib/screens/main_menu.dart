import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  final VoidCallback onStartGame;

  const MainMenuScreen({Key? key, required this.onStartGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Artisans of Fortuna',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'A Tale of Potions, Forges, and Fletching',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: onStartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Enter the Kingdom',
                style: TextStyle(fontSize: 24, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
