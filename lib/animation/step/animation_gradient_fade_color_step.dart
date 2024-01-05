import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class GradientFadeColorStep extends AnimationStep {
  Color get startColor => colors[0];
  Color get endColor => colors[1];

  GradientFadeColorStep({
    required int duration,
    required Color startColor,
    required Color endColor,
  }) : super(
            stepType: AnimationStepType.gradientfade,
            colors: [startColor, endColor],
            duration: duration);
  @override
  List<Color> getCurrentColors(int currentTime, int ledCount) {
    return List.generate(ledCount, (int i) {
      double iNormalized = i / (ledCount - 1); // Normalize i to range 0.0 - 1.0
      int r = ((1 - iNormalized) * startColor.red + iNormalized * endColor.red)
          .round();
      int g =
          ((1 - iNormalized) * startColor.green + iNormalized * endColor.green)
              .round();
      int b =
          ((1 - iNormalized) * startColor.blue + iNormalized * endColor.blue)
              .round();
      return Color.fromARGB(255, r, g, b);
    });
  }

  Color get _color => colors[0];

  @override
  Map<String, dynamic> toJson() => {
        'type': 'solid',
        'duration': duration,
        'color': [
          [_color.red, _color.green, _color.blue]
        ],
      };

  @override
  List<(String, Color, int)> getColorConfig() {
    return [("Start:", startColor, 0), ("End:", endColor, 1)];
  }
}
