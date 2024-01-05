import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/step/animation_fade_color_step.dart';
import 'package:inlinerapp/animation/step/animation_solid_color_step.dart';


void main() {
  group("AnimationModel", () {
    final mockAnimationModel = AnimationModel(
      name: 'Test Animation',
      loop: true,
      steps: [
        SolidColorStep(
            duration: 1000, color: const Color.fromARGB(255, 244, 67, 54)),
        FadeColorStep(
            duration: 1000,
            startColor: const Color.fromARGB(255, 244, 67, 54),
            endColor: const Color.fromARGB(255, 76, 175, 80)),
      ],
    );

    final mockAnimationModelBinary = [
      // Name
      84,
      101,
      115,
      116,
      32,
      65,
      110,
      105,
      109,
      97,
      116,
      105,
      111,
      110,
      ...List.filled(128 - 14,
          32), // ASCII values of "Test Animation", padded to 128 bytes
      // Loop
      1,
      // SolidColorStep
      // Step size
      0x00, 0x09, // Step size = 9 bytes
      // Type ID
      0x00, 0x01,
      // Duration
      0x03, 0xE8,
      // Number of colors
      0x00, 0x01,
      // Color
      244, 67, 54,
      // FadeColorStep
      // Step size
      0x00, 12, // Step size = 12 bytes
      // Type ID
      0x00, 0x02,
      // Duration
      0x03, 0xE8,
      // Number of colors
      0x00, 0x02,
      // Colors
      244, 67, 54, 76, 175, 80,
    ];

    test("toJson should return correct JSON format", () {
      expect(mockAnimationModel.toJson(), {
        'name': 'Test Animation',
        'loop': true,
        'steps': [
          {
            'type': 'solid',
            'duration': 1000,
            'color': [
              [244, 67, 54]
            ]
          },
          {
            'type': 'fade',
            'duration': 1000,
            'color': [
              [244, 67, 54],
              [76, 175, 80]
            ],
          }
        ]
      });
    });

    test("fromJson should correctly recreate AnimationModel", () {
      var json = {
        'name': 'Test Animation',
        'loop': true,
        'steps': [
          {
            'type': 'solid',
            'duration': 1000,
            'color': [
              [244, 67, 54]
            ],
          },
          {
            'type': 'fade',
            'duration': 1000,
            'color': [
              [244, 67, 54],
              [76, 175, 80]
            ],
          }
        ]
      };

      expect(AnimationModel.fromJson(json), mockAnimationModel);
    });

    test("toBinary should return correct binary data", () {
      expect(mockAnimationModel.toBinary(), mockAnimationModelBinary);
    });

    test("fromBinary should correctly recreate AnimationModel", () {
      expect(AnimationModel.fromBinary(mockAnimationModelBinary),
          mockAnimationModel);
    });
  });
}
