import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inlinerapp/animation/step/animation_fade_color_step.dart';
import 'package:inlinerapp/animation/step/animation_solid_color_step.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

void main() {
  group('AnimationStep', () {
    group("FadeStep", () {
      test("Create Fade Animation", () {
        Color startColor = Colors.yellow;
        Color endColor = Colors.red;
        int duration = 1000;
        FadeColorStep fadeColorStep = FadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);

        expect(fadeColorStep.stepType, AnimationStepType.fade);
        expect(fadeColorStep.duration, duration);
        expect(fadeColorStep.startColor, startColor);
        expect(fadeColorStep.endColor, endColor);
      });

      test("Fade Animation to json", () {
        Color startColor = Colors.yellow;
        Color endColor = Colors.red;
        int duration = 1000;
        FadeColorStep fadeColorStep = FadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);

        List<int> expectedStartColor = [255, 235, 59];
        List<int> expectedEndColor = [244, 67, 54];
        var json = fadeColorStep.toJson();

        expect(json["duration"], duration);
        expect(json["color"][0], expectedStartColor);
        expect(json["color"][1], expectedEndColor);
        expect(json["type"], "fade");
      });

      test("Fade Animation to binary", () {
        Color startColor = Colors.yellow;
        Color endColor = Colors.red;
        int duration = 1000;
        FadeColorStep fadeColorStep = FadeColorStep(
            duration: duration, startColor: startColor, endColor: endColor);
        List<int> expectedStartColor = [255, 235, 59];
        List<int> expectedEndColor = [244, 67, 54];

        List<int> expectedBinary = [
          0x00, 0x02, // type id for FadeColorStep, two bytes
          (duration >> 8) & 0xFF, duration & 0xFF, // duration, two bytes
          0x00, 0x02, // number of colors, two byte
          ...expectedStartColor, // start color, three bytes
          ...expectedEndColor, // end color, three bytes
        ];

        List<int> binary = fadeColorStep.toBinary();

        //assert
        expect(binary, expectedBinary);
      });
    });

    group("SolidStep", () {
      test("Create Solid Animation", () {
        Color color = Colors.yellow;
        int duration = 1000;
        SolidColorStep fadeColorStep =
            SolidColorStep(duration: duration, color: color);

        expect(fadeColorStep.stepType, AnimationStepType.solid);
        expect(fadeColorStep.duration, duration);
        expect(fadeColorStep.colors[0], color);
      });

      test("Fade Animation to json", () {
        Color color = Colors.yellow;
        int duration = 1000;
        SolidColorStep fadeColorStep =
            SolidColorStep(duration: duration, color: color);

        List<int> expectedColor = [255, 235, 59];

        var json = fadeColorStep.toJson();

        expect(json["duration"], duration);
        expect(json["color"][0], expectedColor);
        expect(json["type"], "solid");
      });

      test("Fade Animation to binary", () {
        Color color = Colors.yellow;
        int duration = 1000;
        SolidColorStep fadeColorStep =
            SolidColorStep(duration: duration, color: color);

        List<int> expectedColor = [255, 235, 59];
        List<int> expectedBinary = [
          0x00, 0x01, // type id for FadeColorStep, two bytes
          (duration >> 8) & 0xFF, duration & 0xFF, // duration, two bytes
          0x00, 0x01, // number of colors, two byte
          ...expectedColor, // start color, three bytes
        ];

        List<int> binary = fadeColorStep.toBinary();

        //assert
        expect(binary, expectedBinary);
      });
    });
    group("AnimationStepFactory", () {
      test("should create a SolidColorStep", () {
        // Arrange
        Map<String, dynamic> solidColorStepData = {
          'type': 'solid',
          'duration': 500,
          'color': [
            [255, 0, 0],
          ],
        };

        // Act
        AnimationStep step = AnimationStepFactory.fromJson(solidColorStepData);

        // Assert
        expect(step, isA<SolidColorStep>());
        expect(step.duration, equals(500));
        expect(step.colors[0], equals(const Color.fromARGB(255, 255, 0, 0)));
      });

      test("should create a FadeColorStep", () {
        // Arrange
        Map<String, dynamic> fadeColorStepData = {
          'type': 'fade',
          'duration': 1000,
          'color': [
            [255, 0, 0],
            [0, 255, 0],
          ],
        };

        // Act
        AnimationStep step = AnimationStepFactory.fromJson(fadeColorStepData);

        // Assert
        expect(step, isA<FadeColorStep>());
        expect(step.duration, equals(1000));
        expect(step.colors[0], equals(const Color.fromARGB(255, 255, 0, 0)));
        expect(step.colors[1], equals(const Color.fromARGB(255, 0, 255, 0)));
      });

      test("should throw for unknown type", () {
        // Arrange
        Map<String, dynamic> invalidStepData = {
          'type': 'invalidType',
          'duration': 1000,
          'color': [
            [255, 0, 0],
          ],
        };

        // Act & Assert
        expect(() => AnimationStepFactory.fromJson(invalidStepData),
            throwsA(isA<Exception>()));
      });

      test("should throw for invalid color data", () {
        // Arrange
        Map<String, dynamic> invalidColorStepData = {
          'type': 'solid',
          'duration': 1000,
          'color': [
            [255, 0],
          ],
        };

        // Act & Assert
        expect(() => AnimationStepFactory.fromJson(invalidColorStepData),
            throwsA(isA<Exception>()));
      });
    });
    group("AnimationStepFactory fromBinary", () {
      test("should create a SolidColorStep", () {
        // Arrange
        List<int> binaryData = [
          0x00, 0x01, // Type ID: 1 for SolidColorStep
          0x01, 0xF4, // Duration: 500
          0x00, 0x01, // Number of colors: 1
          255, 0, 0, // Color: Red
        ];

        // Act
        AnimationStep step = AnimationStepFactory.fromBinary(binaryData);
        List<int> binary = step.toBinary();

        // Assert
        expect(step, isA<SolidColorStep>());
        expect(step.duration, equals(500));
        expect(step.colors[0], equals(const Color.fromARGB(255, 255, 0, 0)));
        expect(binaryData, binary);
      });

      test("should create a FadeColorStep", () {
        // Arrange
        List<int> binaryData = [
          0x00, 0x02, // Type ID: 2 for FadeColorStep
          0x03, 0xE8, // Duration: 1000
          0x00, 0x02, // Number of colors: 2
          255, 0, 0, // Start Color: Red
          0, 255, 0, // End Color: Green
        ];

        // Act
        AnimationStep step = AnimationStepFactory.fromBinary(binaryData);
        List<int> binary = step.toBinary();
        // Assert
        expect(step, isA<FadeColorStep>());
        expect(step.duration, equals(1000));
        expect(step.colors[0], equals(const Color.fromARGB(255, 255, 0, 0)));
        expect(step.colors[1], equals(const Color.fromARGB(255, 0, 255, 0)));

        expect(binaryData, binary);
      });

      test("should throw for unknown type ID", () {
        // Arrange
        List<int> binaryData = [
          0xFF, 0xFF, // Unknown Type ID: 3
          0x01, 0xF4, // Duration: 500
          0x00, 0x01, // Number of colors: 1
          255, 0, 0, // Color: Red
        ];

        // Act & Assert
        expect(() => AnimationStepFactory.fromBinary(binaryData),
            throwsA(isA<Exception>()));
      });
    });
  });
}
