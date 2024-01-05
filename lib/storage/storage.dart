import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/animation_serializer.dart';
import 'package:inlinerapp/animation/step/animation_fade_color_step.dart';
import 'package:inlinerapp/animation/step/animation_gradient_fade_color_step.dart';
import 'package:inlinerapp/animation/step/animation_rainbow_color_step.dart';
import 'package:inlinerapp/animation/step/animation_random_flash_color_step.dart';
import 'package:inlinerapp/animation/step/animation_solid_color_step.dart';
import 'package:inlinerapp/animation/step/animation_wave_color_step.dart';
import 'package:inlinerapp/storage/storage_device.dart';
import 'package:localstorage/localstorage.dart';

class Storage {
  final storage = LocalStorage('storage.json');
  final _devicesStorageKey = "devices";
  final _animationStorageKey = "animation";

  final StreamController<List<StorageDevice>> _streamController =
      StreamController();

  Stream<List<StorageDevice>> get stream => _streamController.stream;

  List<StorageDevice> loadDeviceList() {
    List<dynamic>? deviceListJson = storage.getItem(_devicesStorageKey);
    if (deviceListJson == null) {
      return List.empty(growable: true);
    }

    try {
      return StorageDeviceList.fromJson(deviceListJson).devices;
    } catch (e) {
      print(e);
    }

    return List.empty(growable: true);
  }

  void saveDeviceList(List<StorageDevice> devices) {
    StorageDeviceList storageDeviceList = StorageDeviceList(devices: devices);

    List<Map<String, dynamic>> json = storageDeviceList.toJSONEncodable();

    storage.setItem(_devicesStorageKey, json);

    _streamController.add(devices);
  }

  List<AnimationModel> loadAnimations() {
    List<dynamic>? animationJson = storage.getItem(_animationStorageKey);
    if (animationJson == null) {
      return [
        AnimationModel(name: "test", loop: true, steps: [
          SolidColorStep(
            color: Colors.yellow,
            duration: 1000,
          ),
          FadeColorStep(
            startColor: const Color.fromARGB(255, 0, 0, 255),
            endColor: const Color.fromARGB(255, 0, 255, 60),
            duration: 1000,
          ),
          FadeColorStep(
            startColor: const Color.fromARGB(255, 0, 255, 60),
            endColor: const Color.fromARGB(255, 0, 0, 255),
            duration: 1000,
          ),
          GradientFadeColorStep(
              duration: 1000, startColor: Colors.pink, endColor: Colors.green),
          RainbowColorStep(duration: 5000),
          WaveColorStep(
              duration: 1000, startColor: Colors.pink, endColor: Colors.green)
        ]),
        AnimationModel(name: "Police 👮", loop: true, steps: [
          SolidColorStep(
            color: const Color.fromARGB(255, 255, 0, 0),
            duration: 200,
          ),
          SolidColorStep(
            color: const Color.fromARGB(255, 0, 0, 255),
            duration: 200,
          ),
          SolidColorStep(
            color: const Color.fromARGB(255, 255, 255, 255),
            duration: 200,
          ),
        ]),
        AnimationModel(
            name: "Rainbow 🌈",
            loop: true,
            steps: [RainbowColorStep(duration: 2000)]),
        AnimationModel(name: "Wave", loop: true, steps: [
          WaveColorStep(
              duration: 1000, startColor: Colors.pink, endColor: Colors.green)
        ]),
        AnimationModel(name: "Flash", loop: true, steps: [
          RandomFlashColorStep(
            duration: 1000,
          )
        ])
      ];
    }
    return AnimationSerializer.fromJson(animationJson);
  }

  void saveAnimations(List<AnimationModel> animations) {
    AnimationSerializer.toJson(animations);
  }
}
