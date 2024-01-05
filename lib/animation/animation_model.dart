import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class AnimationModel {
  String name;
  final bool loop;
  final List<AnimationStep> steps;

  AnimationModel({
    required this.name,
    required this.loop,
    required this.steps,
  });

  dynamic toJson() {
    return {
      'name': name,
      'loop': loop,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  static AnimationModel fromJson(dynamic json) {
    if (json == null ||
        json['name'] == null ||
        json['loop'] == null ||
        json['steps'] == null) {
      throw const FormatException("Invalid or null JSON provided");
    }
    return AnimationModel(
      name: json['name'] ?? '',
      loop: json['loop'] ?? false,
      steps: (json['steps'] is List)
          ? json['steps']
              .map<AnimationStep>((e) => AnimationStepFactory.fromJson(e))
              .toList()
          : [],
    );
  }

  List<int> toBinary() {
    List<int> binaryData = [];
    // Adding name (padded or trimmed to 128 bytes)
    binaryData.addAll(
        const AsciiEncoder().convert(name.padRight(128).substring(0, 128)));
    // Adding loop
    binaryData.add(loop ? 1 : 0);

    // Adding steps
    for (var step in steps) {
      List<int> stepBinary = step.toBinary();
      // Adding step size (2 bytes)
      binaryData
        ..add((stepBinary.length >> 8) & 0xFF)
        ..add(stepBinary.length & 0xFF);
      // Adding step binary data
      binaryData.addAll(stepBinary);
    }

    return binaryData;
  }

  static AnimationModel fromBinary(List<int> binaryData) {
    // Extracting name
    String name = String.fromCharCodes(binaryData.sublist(0, 128)).trim();
    // Extracting loop
    bool loop = binaryData[128] == 1;

    // Extracting steps
    List<AnimationStep> steps = [];
    int cursor = 129; // Start reading after name and loop.

    while (cursor < binaryData.length) {
      // Extract the size of the current step binary data chunk. The size should be stored in 2 bytes.
      int stepSize = (binaryData[cursor] << 8) | binaryData[cursor + 1];
      cursor += 2; // Move cursor to the start of the step data.

      // Extract the step binary data chunk and decode it.
      List<int> stepData = binaryData.sublist(cursor, cursor + stepSize);
      steps.add(AnimationStepFactory.fromBinary(stepData));

      if (cursor + stepSize > binaryData.length) {
        throw const FormatException("Unexpected end of binary data");
      }
      cursor += stepSize;
    }

    return AnimationModel(name: name, loop: loop, steps: steps);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    bool isEqual = other is AnimationModel &&
        other.name == name &&
        other.loop == loop &&
        listEquals(other.steps, steps);

    return isEqual;
  }

  @override
  int get hashCode => name.hashCode ^ loop.hashCode ^ steps.hashCode;
}
