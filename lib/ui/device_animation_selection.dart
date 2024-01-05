import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:provider/provider.dart';

class DeviceAnimationSelection extends StatelessWidget {
  final Characteristic animationConfigCharacteristic;
  final Characteristic currentAnimationCharacteristic;

  const DeviceAnimationSelection(
      {required this.animationConfigCharacteristic,
      required this.currentAnimationCharacteristic,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => _DeviceAnimationSelection(
            DeviceAnimationSelectionModel(
                animationConfigCharacteristic: animationConfigCharacteristic,
                currentAnimationCharacteristic:
                    currentAnimationCharacteristic)),
      );
}

class _DeviceAnimationSelection extends StatefulWidget {
  final DeviceAnimationSelectionModel _deviceAnimationSelectionModel;

  const _DeviceAnimationSelection(this._deviceAnimationSelectionModel);

  @override
  State<_DeviceAnimationSelection> createState() =>
      _DeviceAnimationSelectionState();
}

class DeviceAnimationSelectionModel {
  final Characteristic animationConfigCharacteristic;
  final Characteristic currentAnimationCharacteristic;

  DeviceAnimationSelectionModel(
      {required this.animationConfigCharacteristic,
      required this.currentAnimationCharacteristic});

  Future<AnimationControllerConfig> getAnimationConfig() async {
    List<int> buffer = await animationConfigCharacteristic.read();
    return AnimationControllerConfig.fromBytes(buffer);
  }

  void setCurrentAnimation(int index) {
    final buffer = ByteData(4);
    buffer.setInt32(
        0, index, Endian.little); // Assuming little-endian byte order
    final value = buffer.buffer.asUint8List();
    currentAnimationCharacteristic.write(value);
  }
}

class AnimationControllerConfig {
  final List<AnimationConfig> _list = List.empty(growable: true);

  AnimationControllerConfig.empty();

  AnimationControllerConfig.fromBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    int animationCount = bytes[0];
    for (var i = 0; i < animationCount; i++) {
      int from = (i * 36) + 1;
      int to = (i * 36) + 1 + 36;
      _list.add(AnimationConfig.fromBytes(bytes.sublist(from, to)));
    }
  }
}

class AnimationConfig {
  int updateTime = 0;
  String name = "";

  AnimationConfig.empty();

  @override
  AnimationConfig.fromBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    final buffer = ByteData.sublistView(Uint8List.fromList(bytes));
    updateTime = buffer.getUint32(0, Endian.little);
    name = String.fromCharCodes(
        buffer.buffer.asUint8List(4, buffer.buffer.lengthInBytes - 4));
  }
}

class _DeviceAnimationSelectionState extends State<_DeviceAnimationSelection> {
  AnimationControllerConfig _animationControllerConfig =
      AnimationControllerConfig.empty();
  int _selectedIndex = 0; // Keep track of the selected index

  @override
  void initState() {
    widget._deviceAnimationSelectionModel
        .getAnimationConfig()
        .then((value) => updateAnimationConfig(value));
    super.initState();
  }

  void updateAnimationConfig(
      AnimationControllerConfig animationControllerConfig) {
    setState(() {
      _animationControllerConfig = animationControllerConfig;
      if (_animationControllerConfig._list.isNotEmpty) {
        _selectedIndex = 0; // Default to first item.
      }
    });
  }

  void onAnimationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    widget._deviceAnimationSelectionModel.setCurrentAnimation(index);
  }

  Widget _drawAnimationSelection() {
    if (_animationControllerConfig._list.isEmpty) {
      return const Card(
          margin: EdgeInsets.all(10),
          child: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ));
    }
    return DropdownButton<int>(
      // Working with int instead of String
      value: _selectedIndex,
      items: List.generate(
        _animationControllerConfig._list.length,
        (index) => DropdownMenuItem<int>(
          value: index,
          child: Text(_animationControllerConfig._list[index].name),
        ),
      ),
      onChanged: (newIndex) {
        onAnimationSelected(newIndex ?? 0);
      },
      hint: const Text(
          "Select Animation"), // Show a hint when nothing is selected
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Animation",
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            _drawAnimationSelection(),
          ],
        ),
      ),
    );
  }
}
