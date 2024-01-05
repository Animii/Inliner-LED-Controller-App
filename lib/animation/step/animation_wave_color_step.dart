import 'dart:math';
import 'dart:ui';

import 'package:inlinerapp/animation/step/animation_step.dart';

class WaveColorStep extends AnimationStep {
  Color get startColor => colors[0];
  Color get endColor => colors[1];

  WaveColorStep({
    required int duration,
    required Color startColor,
    required Color endColor,
  }) : super(
            stepType: AnimationStepType.wave,
            colors: [startColor, endColor],
            duration: duration);

  @override
  List<Color> getCurrentColors(int currentTime, int ledCount) {
    double t = currentTime / duration; // Normalized time between 0 and 1.
    double cycle = t * 2 * pi; // Map time to a full trigonometric cycle.

    return List.generate(ledCount, (int i) {
      double iNormalized = i / (ledCount - 1); // Normalize i to range 0.0 - 1.0

      // Generating wave motion by using sine wave
      double waveFactor = (sin(cycle + 2 * pi * iNormalized) + 1) / 2;
      
      int r = ((1 - waveFactor) * startColor.red + waveFactor * endColor.red).round();
      int g = ((1 - waveFactor) * startColor.green + waveFactor * endColor.green).round();
      int b = ((1 - waveFactor) * startColor.blue + waveFactor * endColor.blue).round();
      
      return Color.fromARGB(255, r, g, b);
    });
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'wave',
        'duration': duration,
        'color': [
          [startColor.red, startColor.green, startColor.blue],
          [endColor.red, endColor.green, endColor.blue]
        ],
      };

  @override
  List<(String, Color, int)> getColorConfig() {
    return [("Start:", startColor, 0), ("End:", endColor, 1)];
  }
}