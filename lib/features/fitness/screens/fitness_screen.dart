import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tenkai/core/design_system/tenkai.dart';
import 'package:tenkai/features/fitness/widgets/steps_widget.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // fetch health data from the last 24 hours
    // List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
    //  now.subtract(Duration(days: 1)), now, types);

    // write steps and blood glucose
    // bool success = await health.writeHealthData(10, HealthDataType.STEPS, now, now);
    // success = await health.writeHealthData(3.1, HealthDataType.BLOOD_GLUCOSE, now, now);

    // you can also specify the recording method to store in the metadata (default is RecordingMethod.automatic)
    // on iOS only `RecordingMethod.automatic` and `RecordingMethod.manual` are supported
    // Android additionally supports `RecordingMethod.active` and `RecordingMethod.unknown`
    // success &= await health.writeHealthData(10, HealthDataType.STEPS, now, now, recordingMethod: RecordingMethod.manual);

    return Scaffold(
      appBar: AppBar(title: Text('Fitness')),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(child: StepsWidget()),
                Expanded(child: Card()),
              ],
            ),
            ListTile(
              title: Text('Exercises'),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => context.push('/fitness/exercises'),
            ),
            const SizedBox(height: TenkaiSpacing.sm),
            ListTile(
              title: Text('Programs'),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => context.push('/fitness/programs'),
            ),
          ],
        ),
      ),
    );
  }
}
