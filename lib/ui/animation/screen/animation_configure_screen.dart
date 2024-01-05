import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_model.dart';
import 'package:inlinerapp/animation/animation_provider.dart';
import 'package:inlinerapp/animation/animation_simulator.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';
import 'package:inlinerapp/ble/ble_device_connector.dart';
import 'package:inlinerapp/ui/animation/widget/animation_color_display.dart';
import 'package:inlinerapp/ui/animation/widget/animation_step_list.dart';
import 'package:provider/provider.dart';

class AnimationConfigureScreen extends StatelessWidget {
  final AnimationModel animationModel;
  final BleDeviceConnector bleDeviceConnector;
  final TextEditingController _nameController;
  AnimationConfigureScreen(
      {Key? key,
      required this.animationModel,
      required this.bleDeviceConnector})
      : _nameController = TextEditingController(text: animationModel.name),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    bleDeviceConnector.devices.forEach((key, value) {
      value.setAnimation(animationModel);
    });
    return ChangeNotifierProvider(
      create: (context) => AnimationSimulator(animationModel, 64),
      builder: (context, child) => Consumer4<AnimationSimulator, int,
          AnimationProvider, BleDeviceConnector>(
        builder: (_, simulator, animationIndex, animationProvider,
                bledeviceConnector, __) =>
            Scaffold(
          appBar: AppBar(
              title: TextField(
            controller: _nameController,
            onSubmitted: (value) {
              animationModel.name = value;
              animationProvider.updateAnimation(animationIndex, animationModel);
            },
          )),
          body: ListView(
            scrollDirection: Axis.vertical,
            children: [
              ColorDisplay(
                colors: simulator.getCurrentColors(),
              ),
              AnimationStepList(
                animationStepList:
                    animationProvider.animations[animationIndex].steps,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _addAnimationStep(context, animationProvider, animationIndex);
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _addAnimationStep(BuildContext context,
      AnimationProvider animationProvider, int animationIndex) {
    // Navigate to a new screen, or show a dialog, where the user
    // can configure a new AnimationStep. When done, add it to the
    // animationProvider. You'll need to implement AnimationStepConfigurationScreen.

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => _AnimationStepConfigurationScreen(
        onSave: (newStep) {
          animationProvider.animations[animationIndex].steps.add(newStep);
        },
      ),
    ));
  }
}

class _AnimationStepConfigurationScreen extends StatefulWidget {
  final ValueChanged<AnimationStep> onSave;

  const _AnimationStepConfigurationScreen({
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  _AnimationStepConfigurationScreenState createState() =>
      _AnimationStepConfigurationScreenState();
}

class _AnimationStepConfigurationScreenState
    extends State<_AnimationStepConfigurationScreen> {
  AnimationStepType _selectedType = AnimationStepType.solid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Animation Step'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButton<AnimationStepType>(
          value: _selectedType,
          items: AnimationStepType.values.map((type) {
            return DropdownMenuItem<AnimationStepType>(
              value: type,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedType = newValue ?? AnimationStepType.solid;
            });
          },
          hint: const Text('Select an Animation Step Type'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newStep = AnimationStepFactory.fromType(_selectedType);

          widget.onSave(newStep);
          Navigator.of(context).pop();
        }, // Disable the button if type is not selected.
        child: const Icon(Icons.save),
      ),
    );
  }
}
