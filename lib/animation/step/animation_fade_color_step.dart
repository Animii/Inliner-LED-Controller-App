import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class FadeColorStep extends AnimationStep {
  Color get startColor => colors[0];
  Color get endColor => colors[1];

  FadeColorStep(
      {required int duration,
      required Color startColor,
      required Color endColor})
      : super(
            stepType: AnimationStepType.fade,
            colors: [startColor, endColor],
            duration: duration);

  @override
  List<Color> getCurrentColors(int currentTime, int ledCount) {
    // Logic to compute the current color based on the fade from startColor to endColor.
    double t = currentTime / duration;
    int r = ((1 - t) * startColor.red + t * endColor.red).round();
    int g = ((1 - t) * startColor.green + t * endColor.green).round();
    int b = ((1 - t) * startColor.blue + t * endColor.blue).round();
    Color interpolatedColor = Color.fromARGB(255, r, g, b);

    return List<Color>.filled(ledCount, interpolatedColor);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': stepType.name,
        'duration': duration,
        'color': [
          [startColor.red, startColor.green, startColor.blue],
          [endColor.red, endColor.green, endColor.blue]
        ],
      };

  @override
  List<(String, Color, int)> getColorConfig() {
    return [("From:", startColor, 0), ("To", endColor, 1)];
  }
}
