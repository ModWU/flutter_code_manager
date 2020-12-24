import 'dart:collection';

import 'package:flutter/material.dart';

class StepperDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<StepperDemo> {
  List<Step> _steps = [Step(
    title: Text('2020-4-23'),
    subtitle: Text('田读帅'),
    content: Text('今天是2020-4-23'),
    state: StepState.editing,
  )];

  @override
  Widget build(BuildContext context) {
    print("stepper build");
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        print("stepper StatefulBuilder build");

        List<Step> all = List.from(_steps);

        all.add(null);


        /*Step firstStep;
        if (_steps.isNotEmpty) {
          firstStep = _steps.removeAt(0);
        }

        if (firstStep != null) {
          Step secondStep = Step(
            title: firstStep.title,
            subtitle: firstStep.subtitle,
            content: firstStep.content,
            state: StepState.complete,
          );

          firstStep = Step(
            title: firstStep.title,
            subtitle: firstStep.subtitle,
            content: firstStep.content,
            state: StepState.editing,
          );

          List<Step> _oldSteps = List.from(_steps);
          _steps = [];

          while (_oldSteps.isNotEmpty) {
            Step step = _oldSteps.removeAt(0);
            _steps.add(Step(
              title: step.title,
              subtitle: step.subtitle,
              content: step.content,
              state: StepState.indexed,
            ));
          }

          _steps.insert(0, secondStep);

        } else {
          firstStep = Step(
            title: Text('2020-4-23'),
            subtitle: Text('田读帅'),
            content: Text('今天是2020-4-23'),
            state: StepState.editing,
          );
        }

        _steps.insert(0, firstStep);*/

        return Stepper(
          steps: all,
          onStepCancel: () {
            print('onStepCancel');
          },
          onStepContinue: () {
            print('onStepContinue');
            setState((){});
          },
          onStepTapped: (index) {
            print('onStepTapped:$index');
          },
        );
      },
    );
  }
}
