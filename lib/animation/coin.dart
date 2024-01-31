import 'package:flutter/material.dart';
import 'dart:math' as math;

class PointFlip extends StatefulWidget {
  final double points;

  PointFlip({required this.points});

  @override
  _PointFlipState createState() => _PointFlipState();
}

class _PointFlipState extends State<PointFlip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: child,
        );
      },
      child: Image.asset(
        'assets/coin.png',
        width: 120,
        height: 120,
      ),
    );
  }
}

class CoinFlip extends StatefulWidget {
  final double money;

  CoinFlip({required this.money});

  @override
  _CoinFlipState createState() => _CoinFlipState();
}

class _CoinFlipState extends State<CoinFlip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: child,
        );
      },
      child: Image.asset(
        'assets/goen.png',
        width: 120,
        height: 120, 
      ),
    );
  }
}
