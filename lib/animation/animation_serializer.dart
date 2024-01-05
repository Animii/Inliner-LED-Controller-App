import 'package:inlinerapp/animation/animation_model.dart';

class AnimationSerializer {
  static dynamic toJson(List<AnimationModel> animations) {
    return animations.map((animation) => animation.toJson()).toList();
  }

  static List<AnimationModel> fromJson(List<dynamic> json) {
    return json.map<AnimationModel>((e) => AnimationModel.fromJson(e)).toList();
  }

  static List<int> toBinary(List<AnimationModel> animations) {
    List<int> binaryData = [];
    // Adding the number of animations (assuming it will be less than 65536, using 2 bytes)
    binaryData
      ..add((animations.length >> 8) & 0xFF)
      ..add(animations.length & 0xFF);

    for (var animation in animations) {
      List<int> animationBinary = animation.toBinary();
      // Adding animation size (2 bytes)
      binaryData
        ..add((animationBinary.length >> 8) & 0xFF)
        ..add(animationBinary.length & 0xFF);
      // Adding animation binary data
      binaryData.addAll(animationBinary);
    }

    return binaryData;
  }

  static List<AnimationModel> fromBinary(List<int> binaryData) {
    List<AnimationModel> animations = [];

    int numAnimations = (binaryData[0] << 8) | binaryData[1];
    int cursor = 2; // Start reading after the number of animations.

    for (int i = 0; i < numAnimations; i++) {
      // Extract the size of the current animation binary data chunk. The size should be stored in 2 bytes.
      int animationSize = (binaryData[cursor] << 8) | binaryData[cursor + 1];
      cursor += 2; // Move cursor to the start of the animation data.

      // Extract the animation binary data chunk and decode it.
      List<int> animationData =
          binaryData.sublist(cursor, cursor + animationSize);
      animations.add(AnimationModel.fromBinary(animationData));

      // Move cursor to the next animation.
      cursor += animationSize;
    }

    return animations;
  }
}
