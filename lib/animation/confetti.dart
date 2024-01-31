import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiAnimation extends StatelessWidget {
  final ConfettiController _controller;

  ConfettiAnimation(this._controller);

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirection: 3.14 / 2,
      maxBlastForce: 5,
      minBlastForce: 1,
      emissionFrequency: 0.02,
      numberOfParticles: 10,
      gravity: 0.1,
      shouldLoop: true,
      colors: const [
        Colors.green,
        Colors.yellow,
        Colors.pink,
        Colors.orange,
        Colors.blue
      ],
    );
  }
}
