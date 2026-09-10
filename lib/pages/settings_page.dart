import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Shake Intensity (%): ${settings.sensitivity.round()}'),
            Slider(
              value: settings.sensitivity,
              min: 25,
              max: 100,
              divisions: 3,
              onChanged: (value) =>
                  context.read<SettingsModel>().setSensitivity(value),
            ),
            const SizedBox(height: 24),
            Text('Countdown: ${settings.countdown} seconds'),
            DropdownButton<int>(
              value: settings.countdown,
              items: [3, 4, 5, 6, 7, 8, 9, 10]
                  .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsModel>().setCountdown(value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Photo Quality'),
            DropdownButton<String>(
              value: settings.photoQuality,
              items: ['Low', 'Medium', 'High', 'Max']
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsModel>().setPhotoQuality(value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Recording Quality'),
            DropdownButton<String>(
              value: settings.recordingQuality,
              items: ['Low', 'Medium', 'High']
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsModel>().setRecordingQuality(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
