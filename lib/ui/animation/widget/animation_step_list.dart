import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inlinerapp/animation/animation_provider.dart';
import 'package:inlinerapp/animation/animation_simulator.dart';
import 'package:inlinerapp/animation/step/animation_step.dart';
import 'package:inlinerapp/ui/animation/widget/hue_picker.dart';
import 'package:provider/provider.dart';

class AnimationStepList extends StatelessWidget {
  final List<AnimationStep> animationStepList;

  const AnimationStepList({required this.animationStepList, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AnimationStepList();
  }
}

class _AnimationStepList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<AnimationSimulator, AnimationProvider, int>(
      builder: (context, simulator, animationProvider, animationIndex, _) =>
          ReorderableListView.builder(
        shrinkWrap: true,
        itemCount: animationProvider.animations[animationIndex].steps.length,
        itemBuilder: (context, index) {
          final step =
              animationProvider.animations[animationIndex].steps[index];
          return Dismissible(
            key: Key(step.hashCode
                .toString()), // Ensuring that each key is unique by using index.
            direction: DismissDirection.startToEnd, // Swipe direction.
            onDismissed: (direction) {
              // Remove the step from your list.
              // You need to ensure that the state is managed appropriately here.
              animationProvider.removeStepFromAnimation(animationIndex, index);

              // Optionally: show a snackbar.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Step removed')),
              );
            },
            background: Container(
              color: Colors.red, // Add a delete icon.
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                  left:
                      16.0), // You can customize this color as per your requirement.
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: AnimationStepTile(
              step: step,
              isActive: index == simulator.currentStepIndex,
              progress: (index == simulator.currentStepIndex)
                  ? simulator.elapsedTimeInStep / step.duration
                  : (index < simulator.currentStepIndex)
                      ? 1.0
                      : 0.0,
            ), // Your tile goes here.
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) {
            // Reducing newIndex by 1 to maintain correct order after removal.
            newIndex -= 1;
          }
          List<AnimationStep> steps =
              List.from(animationProvider.animations[animationIndex].steps);
          final item = steps.removeAt(oldIndex);
          steps.insert(newIndex, item);

          // NOTE: Now you should update your animationProvider to reflect these changes.
          animationProvider.updateStepsOrder(animationIndex, steps);
        },
      ),
    );
  }
}

class AnimationStepTile extends StatefulWidget {
  // ... your properties
  final AnimationStep step;
  final bool isActive;
  final double progress;

  const AnimationStepTile({
    required this.step,
    required this.isActive,
    required this.progress,
    Key? key,
  }) : super(key: key);

  @override
  _AnimationStepTileState createState() => _AnimationStepTileState();
}

class _AnimationStepTileState extends State<AnimationStepTile> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = max(widget.step.duration.toDouble(), 50);
  }

  @override
  Widget build(BuildContext context) {
    List<(String name, Color color, int index)> colorConfig =
        widget.step.getColorConfig();
    return ListTile(
      tileColor:
          widget.isActive ? Theme.of(context).colorScheme.onSecondary : null,
      title: Text(widget.step.stepType.name),
      subtitle: Column(
        children: [
          _buildColors(context, colorConfig),
          LinearProgressIndicator(value: widget.progress),
          Slider(
            onChanged: (value) {
              _sliderValue = value;
            },
            value: max(_sliderValue, 50),
            min: 50,
            max: 5000, // 5000 milliseconds or 5 seconds for example
            divisions: (5000 - 50) ~/
                50, // number of 50ms increments between 0 and 5000ms
            label: '${_sliderValue.toInt()} ms',
            onChangeEnd: (newDuration) {
              _sliderValue = newDuration;
              widget.step.setDuration(newDuration.toInt());
            },
          ),
        ],
      ),
    );
  }

  Row _buildColors(
      BuildContext context, List<(String, Color, int)> colorConfig) {
    return Row(
      children: [
        ...colorConfig
            .map((config) => Expanded(
                  child: GestureDetector(
                    onTap: () => _showColorPicker(
                        context, config.$1, config.$2, config.$3),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: config.$2,
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Color getContrastColor(Color color) {
    // Logic to determine a contrasting color (usually white or black)
    // to ensure text is readable against the passed color.
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  void _showColorPicker(
      BuildContext context, String name, Color currentColor, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a color for $name',
              style: Theme.of(context).textTheme.labelMedium),
          content: SingleChildScrollView(
            child: HuePicker(
              onHueChanged: (double hue) {
                widget.step
                    .setColor(index, HSVColor.fromAHSV(1, hue, 1, 1).toColor());
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
