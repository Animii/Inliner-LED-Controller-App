import 'package:flutter/material.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';

class ColorDisplay extends StatelessWidget {
  final List<Color> colors;

  const ColorDisplay({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors
          .map((color) => Flexible(
                child: AspectRatio(
                  aspectRatio: 0.1,
                  child: Container(
                    color: color,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class ColorBleDisplay extends StatelessWidget {
  final List<Color> colors;
  final BleDeviceConnector bledeviceConnector;
  const ColorBleDisplay(
      {super.key, required this.colors, required this.bledeviceConnector});

  @override
  Widget build(BuildContext context) {
    bledeviceConnector.devices.forEach((key, value) {
      value.sendColor(colors);
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors
          .map((color) => Flexible(
                child: AspectRatio(
                  aspectRatio: 0.1,
                  child: Container(
                    color: color,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
