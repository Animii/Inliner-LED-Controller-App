import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';

class AnimationProvider with ChangeNotifier {
  final List<AnimationModel> _animations = [];

  List<AnimationModel> get animations => _animations;

  void createAnimation(AnimationModel animation) {
    _animations.add(animation);
    notifyListeners();
  }

  void updateAnimation(int index, AnimationModel animation) {
    _animations[index] = animation;
    notifyListeners();
  }

  void deleteAnimation(int index) {
    _animations.removeAt(index);
    notifyListeners();
  }

  void removeStepFromAnimation(int animationIndex, int stepIndex) {
    _animations[animationIndex].steps.removeAt(stepIndex);
    notifyListeners();
  }

  void updateStepsOrder(int animationIndex, List<AnimationStep> newOrder) {
    _animations[animationIndex].steps.clear();
    _animations[animationIndex].steps.addAll(newOrder);
    notifyListeners();
  }
}
