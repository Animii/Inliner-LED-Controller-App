import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/animation_provider.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/ui/animation/screen/animation_configure_screen.dart';
import 'package:inlinerapp/ui/animation/widget/animation_viewer.dart';
import 'package:provider/provider.dart';

class AnimationList extends StatelessWidget {
  const AnimationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<AnimationProvider>(
        builder: (_, animationProvider, __) => _AnimationListScreen(
          animationProvider: animationProvider,
        ),
      );
}

class _AnimationListScreen extends StatelessWidget {
  final AnimationProvider animationProvider;

  const _AnimationListScreen({required this.animationProvider});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int?> selectedAnimationIndex = ValueNotifier<int?>(null);
    selectedAnimationIndex.addListener(
      () {},
    );
    return Column(children: [
      Flexible(
        child: ListView.builder(
            itemCount: animationProvider.animations.length,
            itemBuilder: (context, index) => _AnimationListTile(
                animationModel: animationProvider.animations[index],
                animationIndex: index,
                selectedAnimationIndex: selectedAnimationIndex)),
      )
    ]);
  }
}

class _AnimationListTile extends StatelessWidget {
  final AnimationModel animationModel;
  final int animationIndex;
  final ValueNotifier<int?> selectedAnimationIndex;

  const _AnimationListTile(
      {required this.animationModel,
      required this.animationIndex,
      required this.selectedAnimationIndex});

  void openAnimationConfigureScreen(
      BuildContext context, BleDeviceConnector bleDeviceConnector) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Provider.value(
                  value: animationIndex,
                  builder: (context, child) {
                    return AnimationConfigureScreen(
                      animationModel: animationModel,
                      bleDeviceConnector: bleDeviceConnector,
                    );
                  },
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleDeviceConnector>(
      builder: (context, bleDeviceConnector, child) => Card(
        color: selectedAnimationIndex.value == animationIndex
            ? Colors.blue.withOpacity(0.2)
            : null, // Highlight if selected
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(animationModel.name),
          onTap: () {
            bleDeviceConnector.devices.forEach((key, value) {
              value.setAnimation(animationModel);
            });
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double dynamicWidth = constraints.maxWidth > 200.0
                      ? 200.0
                      : constraints.maxWidth;
                  return SizedBox(
                    height: 30.0,
                    width: dynamicWidth,
                    child: AnimationViewer(
                      animationModel: animationModel,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Provider.value(
                        value: animationIndex,
                        builder: (context, child) {
                          return AnimationConfigureScreen(
                            animationModel: animationModel,
                            bleDeviceConnector: bleDeviceConnector,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
