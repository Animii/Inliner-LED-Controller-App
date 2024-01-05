import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class RainbowColorStep extends AnimationStep {
  RainbowColorStep({required int duration})
      : super(
            stepType: AnimationStepType.rainbow,
            colors: [],
            duration: duration); // Single color not used.

  @override
  List<Color> getCurrentColors(int currentTime, int ledCount) {
    double t = currentTime / duration; // Normalized time between 0 and 1.
    double cycle = t * 2 * pi; // Map time to a full trigonometric cycle.

    return List.generate(ledCount, (int i) {
      double iNormalized = i / (ledCount - 1); // Normalize i to range 0.0 - 1.0
      int r = (sin(cycle + 2 * pi * iNormalized) * 127.5 + 127.5).round();
      int g = (sin(cycle + 2 * pi * iNormalized - 2 * pi / 3) * 127.5 + 127.5)
          .round();
      int b = (sin(cycle + 2 * pi * iNormalized + 2 * pi / 3) * 127.5 + 127.5)
          .round();
      return Color.fromARGB(255, r, g, b);
    });
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'rainbow',
        'duration': duration,
        'color': [], // No fixed colors used in rainbow animation.
      };

  @override
  List<(String, Color, int)> getColorConfig() {
    return [];
  }
}
