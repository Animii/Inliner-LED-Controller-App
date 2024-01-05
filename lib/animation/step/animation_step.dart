import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/step/animation_fade_color_step.dart';
import 'package:inlinerapp/animation/step/animation_gradient_fade_color_step.dart';
import 'package:inlinerapp/animation/step/animation_rainbow_color_step.dart';
import 'package:inlinerapp/animation/step/animation_random_flash_color_step.dart';
import 'package:inlinerapp/animation/step/animation_solid_color_step.dart';
import 'package:inlinerapp/animation/step/animation_wave_color_step.dart';

enum AnimationStepType {
  solid,
  fade,
  gradientfade,
  rainbow,
  wave,
  randomflash
  // Add more step types here...
}

Map<AnimationStepType, int> animationStepTypeToId = {
  AnimationStepType.solid: 1,
  AnimationStepType.fade: 2,
  AnimationStepType.gradientfade: 3,
  AnimationStepType.rainbow: 4,
  AnimationStepType.wave: 5,
  AnimationStepType.randomflash: 6

  // Add more step types here...
};

Map<int, AnimationStepType> idToAnimationStepType = {
  1: AnimationStepType.solid,
  2: AnimationStepType.fade,
  3: AnimationStepType.gradientfade,
  4: AnimationStepType.rainbow,
  5: AnimationStepType.wave,
  6: AnimationStepType.randomflash
  // Add more step types here...
};

abstract class AnimationStep {
  final AnimationStepType stepType;
  int duration; // Duration in milliseconds
  final List<Color> colors;
  AnimationStep(
      {required this.stepType, required this.colors, required this.duration});

  List<Color> getCurrentColors(int currentTime, int ledCount);
  Map<String, dynamic> toJson();

  List<(String name, Color color, int index)> getColorConfig();

  void setColor(int index, Color color) {
    colors[index] = color;
  }

  List<int> toBinary() {
    List<int> binaryData = [];

    int? typeId = animationStepTypeToId[stepType];
    if (typeId == null) {
      throw Exception("Unknown animation step type: $typeId");
    }
    //Adding typeId
    binaryData
      ..add((typeId >> 8) & 0xFF)
      ..add(typeId & 0xFF);
    // Adding duration
    binaryData
      ..add((duration >> 8) & 0xFF)
      ..add(duration & 0xFF);
    // Adding the number of colors (2 bytes)
    binaryData
      ..add((colors.length >> 8) & 0xFF)
      ..add(colors.length & 0xFF);
    // Adding color bytes
    for (var c in colors) {
      binaryData
        ..add(c.red)
        ..add(c.green)
        ..add(c.blue);
    }

    return binaryData;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimationStep &&
        other.stepType == stepType &&
        other.duration == duration &&
        listEquals(other.colors, colors);
  }

  @override
  int get hashCode => duration.hashCode ^ colors.hashCode;

  void setDuration(int newDuration) {
    if (newDuration < 1) {
      newDuration = 1;
    }

    duration = newDuration;
  }
}

class AnimationStepFactory {
  static AnimationStep fromJson(Map<String, dynamic> stepData) {
    AnimationStepType type = _typeFromString(stepData['type']);
    int duration = stepData['duration']; // Default duration if not provided

    switch (type) {
      case AnimationStepType.solid:
        Color color = _colorFromList(stepData['color'][0]);
        return SolidColorStep(duration: duration, color: color);

      case AnimationStepType.fade:
        Color startColor = _colorFromList(stepData['color'][0]);
        Color endColor = _colorFromList(stepData['color'][1]);
        return FadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);

      case AnimationStepType.gradientfade:
        Color startColor = _colorFromList(stepData['color'][0]);
        Color endColor = _colorFromList(stepData['color'][1]);
        return GradientFadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);

      case AnimationStepType.rainbow:
        return RainbowColorStep(duration: duration);

      case AnimationStepType.wave:
        return WaveColorStep(
            duration: duration,
            startColor: _colorFromList(stepData['color'][0]),
            endColor: _colorFromList(stepData['color'][1]));

      case AnimationStepType.randomflash:
        return RandomFlashColorStep(duration: duration);
    }
  }

  static AnimationStep fromType(AnimationStepType type) {
    int duration = 1000;

    switch (type) {
      case AnimationStepType.solid:
        return SolidColorStep(duration: duration, color: Colors.white);

      case AnimationStepType.fade:
        Color startColor = Colors.white;
        Color endColor = Colors.white;
        return FadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);

      case AnimationStepType.gradientfade:
        Color startColor = Colors.white;
        Color endColor = Colors.white;
        return GradientFadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);

      case AnimationStepType.rainbow:
        return RainbowColorStep(duration: duration);

      case AnimationStepType.wave:
        return WaveColorStep(
            duration: duration,
            startColor: Colors.white,
            endColor: Colors.white);

      case AnimationStepType.randomflash:
        return RandomFlashColorStep(duration: duration);
    }
  }

  static AnimationStepType _typeFromString(String typeString) {
    try {
      return AnimationStepType.values
          .firstWhereOrNull((element) => element.name == typeString)!;
    } catch (e) {
      throw Exception('Unknown type string: $typeString');
    }
  }

  static Color _colorFromList(List<dynamic> rgb) {
    if (rgb.length != 3) throw Exception('Color data is invalid');
    return Color.fromARGB(255, rgb[0] as int, rgb[1] as int, rgb[2] as int);
  }

  static AnimationStep fromBinary(List<int> binaryData) {
    int typeId = (binaryData[0] << 8) + binaryData[1];
    int duration = (binaryData[2] << 8) + binaryData[3];
    int numberOfColors = (binaryData[4] << 8) + binaryData[5];
    int colorOffset = 6;
    List<Color> colors = [];
    for (int i = 0; i < numberOfColors; i++) {
      colors.add(Color.fromARGB(
          255,
          binaryData[colorOffset + i * 3],
          binaryData[colorOffset + i * 3 + 1],
          binaryData[colorOffset + i * 3 + 2]));
    }

    switch (typeId) {
      case 1: // Assuming 1 is typeId for SolidColorStep
        return SolidColorStep(duration: duration, color: colors[0]);

      case 2: // Assuming 2 is typeId for FadeColorStep
        return FadeColorStep(
            duration: duration, startColor: colors[0], endColor: colors[1]);

      case 3: // Assuming 3 is typeId for GradientFadeColorStep
        return GradientFadeColorStep(
            duration: duration, startColor: colors[0], endColor: colors[1]);

      case 4:
        return RainbowColorStep(duration: duration);

      case 5:
        return WaveColorStep(
            duration: duration, startColor: colors[0], endColor: colors[1]);

      case 6:
        return RandomFlashColorStep(duration: duration);

      default:
        throw Exception("Unknown type ID: $typeId");
    }
  }
}
