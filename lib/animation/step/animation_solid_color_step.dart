import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class SolidColorStep extends AnimationStep {
  SolidColorStep({required int duration, required Color color})
      : super(
            stepType: AnimationStepType.solid,
            colors: [color],
            duration: duration);

  @override
  List<Color> getCurrentColors(int currentTime, int ledCount) {
    return List<Color>.filled(ledCount, _color);
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
    return [("Color:", colors[0], 0)];
  }
}
