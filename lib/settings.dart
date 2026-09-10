import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {
  double _sensitivity = 50.0;
  int _countdown = 3;
  String _photoQuality = 'High';
  String _recordingQuality = 'High';

  double get sensitivity => _sensitivity;
  int get countdown => _countdown;
  String get photoQuality => _photoQuality;
  String get recordingQuality => _recordingQuality;

  void setSensitivity(double value) {
    _sensitivity = value;
    notifyListeners();
  }

  void setCountdown(int value) {
    _countdown = value;
    notifyListeners();
  }

  void setPhotoQuality(String value) {
    _photoQuality = value;
    notifyListeners();
  }

  void setRecordingQuality(String value) {
    _recordingQuality = value;
    notifyListeners();
  }
}
