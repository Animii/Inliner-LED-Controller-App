import 'dart:async';
import 'package:flutter/material.dart';
import 'animation_model.dart';

class AnimationSimulator extends ChangeNotifier {
  late AnimationModel _animation;
  late List<Color> _currentColors;
  late int _currentStepIndex;
  late int _elapsedTimeInStep;
  Timer? _timer;
  final Duration _stepDuration;
  final int _ledCount;
  final int _chunkSize; // Added to define the number of LEDs in each chunk.

  int get currentStepIndex => _currentStepIndex;
  int get elapsedTimeInStep => _elapsedTimeInStep;

  AnimationSimulator(AnimationModel animation, this._ledCount,
      [this._stepDuration = const Duration(milliseconds: 50),
      int chunkSize = 5])
      : _chunkSize = chunkSize {
    // Initialize chunkSize.
    _loadAnimation(animation);
  }

  void _loadAnimation(AnimationModel animation) {
    _animation = animation;
    _currentStepIndex = 0;
    _elapsedTimeInStep = 0;
    if (_animation.steps.isEmpty) {
      _currentColors = List.filled(_ledCount, Colors.black);
      return;
    }
    _currentColors = _generateChunkedColors();
    _startTimer();
  }

  List<Color> _generateChunkedColors() {
    if (_animation.steps.isEmpty) return List.filled(_ledCount, Colors.black);

    // Get the color for the current step.
    Color stepColor = _animation.steps[_currentStepIndex].colors.first;

    // Generate the list of colors in chunks.
    List<Color> chunkedColors = [];
    for (int i = 0; i < _ledCount; i += _chunkSize) {
      chunkedColors.addAll(List.filled(_chunkSize, stepColor));
    }
    return chunkedColors;
  }

  void _startTimer() {
    _timer?.cancel(); // Stop any existing timer.
    _timer = Timer.periodic(_stepDuration, _updateAnimation);
  }

  void _updateAnimation(Timer timer) {
    _elapsedTimeInStep += _stepDuration.inMilliseconds;
    if (_animation.steps.isEmpty ||
        _animation.steps.length <= _currentStepIndex) {
      _currentStepIndex = 0;
      return;
    }
    // If the elapsed time exceeds the duration of the current step, move to the next step.
    if (_elapsedTimeInStep >= _animation.steps[_currentStepIndex].duration) {
      _elapsedTimeInStep = 0; // Reset the elapsed time.

      // Move to the next step or loop to the first step.
      if (_currentStepIndex < _animation.steps.length - 1) {
        _currentStepIndex++;
      } else if (_animation.loop) {
        _currentStepIndex = 0;
      } else {
        _timer?.cancel(); // Stop the timer if the animation doesn't loop.
      }
    }

    _currentColors = _animation.steps[_currentStepIndex]
        .getCurrentColors(_elapsedTimeInStep, _ledCount);

    // Notify listeners that the current colors have changed.
    notifyListeners();

    // Further logic for handling transition effects like fade, etc., could be implemented here.
  }

  List<Color> getCurrentColors() {
    return _currentColors;
  }

  void updateAnimation(AnimationModel animation) {
    _loadAnimation(animation);
    // Notify listeners that a new animation has been loaded.
    notifyListeners();
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Ensure the timer is canceled when the object is disposed.
    super.dispose();
  }
}
