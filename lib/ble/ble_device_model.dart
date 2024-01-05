import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:collection/collection.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/animation_simulator.dart';

class BleDeviceModel {
  final FlutterReactiveBle ble;
  final DeviceConnectionState connectionState;
  final String deviceId;
  final List<Service> services;
  final int mtuSize;
  AnimationSimulator? _simulator;
  bool _isSending = false;

  DateTime _lastSentTimestamp = DateTime.now();
  final Duration _minSendingInterval =
      const Duration(milliseconds: 100); // Adjust accordingly

  BleDeviceModel({
    required this.ble,
    required this.connectionState,
    required this.deviceId,
    required this.services,
    required this.mtuSize,
  });

  List<int> _convertColorToBytes(List<Color> colors) {
    final bytes = <int>[];
    for (final color in colors) {
      bytes.add(color.red);
      bytes.add(color.green);
      bytes.add(color.blue);
    }
    return bytes;
  }

  setAnimation(AnimationModel animationModel) {
    _simulator?.dispose();
    _simulator = AnimationSimulator(
        animationModel, 64, const Duration(milliseconds: 30));
    _simulator?.addListener(() async {
      if (_simulator != null) {
        await sendColor(_simulator!.getCurrentColors());
      }
    });
  }

  Future<void> sendColor(List<Color> colors) async {
    if (connectionState != DeviceConnectionState.connected || _isSending) {
      return;
    }
    _isSending = true;

    final currentTime = DateTime.now();
    if (currentTime.difference(_lastSentTimestamp) < _minSendingInterval) {
      _isSending = false;
      // Skipping send due to rate limiting
      return;
    }
    _lastSentTimestamp = currentTime;

    var syncService = services.firstWhereOrNull((element) =>
        element.id == Uuid.parse("000000ff-0000-1000-8000-00805f9b34fb"));
    var syncCharacteristic = syncService?.characteristics.firstWhereOrNull(
        (element) =>
            element.id == Uuid.parse("0000ff0f-0000-1000-8000-00805f9b34fb"));

    final int maxChunkSize =
        mtuSize - 1; // Subtract 1 to leave room for the offset
    final colorBytes = _convertColorToBytes(colors);

    for (int offset = 0;
        offset < colorBytes.length;
        offset += maxChunkSize - 1) {
      final chunkSize = colorBytes.length - offset >= maxChunkSize - 1
          ? maxChunkSize - 1
          : colorBytes.length - offset;

      final chunk = Uint8List(chunkSize + 1);
      chunk[0] = (offset ~/ 3);

      for (int i = 0; i < chunkSize; i++) {
        chunk[i + 1] = colorBytes[offset + i];
      }

      try {
        await syncCharacteristic?.write(chunk, withResponse: false);
      } catch (e) {
        print(e);
      }
    }

    _isSending = false;
  }

  void dispose() {
    _simulator?.dispose();
    _simulator = null;
  }

  Future<void> setBrightness(double brightness) async {
    if (connectionState != DeviceConnectionState.connected) {
      return;
    }
    if (brightness > 1.0) {
      brightness = 1.0;
    }
    int intBrightness = (brightness * 255).round();

    var syncService = services.firstWhereOrNull((element) =>
        element.id == Uuid.parse("000000ff-0000-1000-8000-00805f9b34fb"));
    var brightnessCharacteristic = syncService?.characteristics
        .firstWhereOrNull((element) =>
            element.id == Uuid.parse("0000ff04-0000-1000-8000-00805f9b34fb"));
    try {
      await brightnessCharacteristic
          ?.write([intBrightness], withResponse: true);
    } catch (e) {
      print(e);
    }
  }
}
