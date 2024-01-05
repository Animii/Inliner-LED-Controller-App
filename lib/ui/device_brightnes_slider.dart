import 'package:flutter/material.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:provider/provider.dart';

class DeviceBrightnessSlider extends StatelessWidget {
  const DeviceBrightnessSlider({super.key});

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => AnimationBrightnessSlider(
            AnimationBrightnessModel(deviceConnector: deviceConnector)),
      );
}

class AnimationBrightnessModel {
  final BleDeviceConnector deviceConnector;
  const AnimationBrightnessModel({required this.deviceConnector});

  Future<double?> getBrightnessOrNull() async {
    return 1;
  }

  Future<void> setBrightness(double brightness) async {
    deviceConnector.devices.forEach(
      (key, value) {
        value.setBrightness(brightness);
      },
    );
  }
}

class AnimationBrightnessSlider extends StatefulWidget {
  final AnimationBrightnessModel _animationBrightnessModel;

  const AnimationBrightnessSlider(this._animationBrightnessModel, {super.key});

  @override
  State<AnimationBrightnessSlider> createState() =>
      _AnimationBrightnessSliderState();
}

class _AnimationBrightnessSliderState extends State<AnimationBrightnessSlider> {
  double? _currentSliderValue; // Initially null indicating loading state.

  @override
  void initState() {
    super.initState();
    widget._animationBrightnessModel
        .getBrightnessOrNull()
        .then((value) => updateSliderValue(value));
  }

  void updateSliderValue(double? value) {
    if (value != null) {
      setState(() {
        _currentSliderValue = value;
      });
    }
  }

  Widget _drawSlider() {
    // Check if _currentSliderValue is null to determine if loading.
    if (_currentSliderValue == null) {
      return const LinearProgressIndicator();
    }

    return Slider(
      value: _currentSliderValue!,
      max: 1,
      min: 0,
      label: _currentSliderValue!.round().toString(),
      onChangeEnd: widget._animationBrightnessModel.setBrightness,
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Text("Brightness", style: Theme.of(context).textTheme.labelSmall),
        Row(
          children: [
            IconButton(
                onPressed: () {
                  if (_currentSliderValue == null) return;
                  double newBrightnessValue = _currentSliderValue! > 0 ? 0 : 1;
                  widget._animationBrightnessModel
                      .setBrightness(newBrightnessValue);
                  updateSliderValue(newBrightnessValue);
                },
                icon: const Icon(Icons.wb_sunny, color: Colors.yellow)),
            Expanded(
              child: _drawSlider(),
            ),
          ],
        ),
      ],
    );
  }
}
