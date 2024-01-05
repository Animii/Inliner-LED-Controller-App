import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/animation_simulator.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/ui/animation/widget/animation_color_display.dart';
import 'package:provider/provider.dart';

class AnimationViewer extends StatelessWidget {
  final AnimationModel animationModel;

  const AnimationViewer({super.key, required this.animationModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AnimationSimulator(animationModel, 60)),
        Provider.value(value: animationModel.name)
      ],
      builder: (context, child) {
        return const _AnimationViewer();
      },
    );
  }
}

class _AnimationViewer extends StatelessWidget {
  const _AnimationViewer();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AnimationSimulator, String>(
      builder: (context, simulator, animationName, __) {
        return ColorDisplay(colors: simulator.getCurrentColors());
      },
    );
  }
}

class AnimationSyncerView extends StatelessWidget {
  final AnimationModel animationModel;
  final BleDeviceConnector bleDeviceConnector;

  const AnimationSyncerView(
      {super.key,
      required this.animationModel,
      required this.bleDeviceConnector});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AnimationSimulator(
                  animationModel,
                  60,
                )),
        Provider.value(value: animationModel.name)
      ],
      builder: (context, child) {
        return const _AnimationSyncerView();
      },
    );
  }
}

class _AnimationSyncerView extends StatelessWidget {
  const _AnimationSyncerView();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AnimationSimulator, BleDeviceConnector>(
      builder: (context, simulator, bledeviceConnector, __) {
        return ColorDisplay(colors: simulator.getCurrentColors());
      },
    );
  }
}
