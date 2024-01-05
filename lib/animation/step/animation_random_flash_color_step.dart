import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class RandomFlashColorStep extends AnimationStep {
  RandomFlashColorStep({
    required int duration,
  }) : super(
            stepType: AnimationStepType.randomflash,
            colors: [],
            duration: duration);

  @override
  List<Color> getCurrentColors(int currentTime, int ledCount) {
    // We'll use currentTime to seed a random number generator.
    // It guarantees that for a given currentTime, the color set will always be the same
    var rng = Random(currentTime);

    return List.generate(ledCount, (int i) {
      // Generating random colors
      int r = rng.nextInt(256);
      int g = rng.nextInt(256);
      int b = rng.nextInt(256);

      return Color.fromARGB(255, r, g, b);
    });
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'randomflash',
        'duration': duration,
        'color': [],
      };

  @override
  List<(String, Color, int)> getColorConfig() {
    return [];
  }
}
