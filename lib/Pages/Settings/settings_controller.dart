import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._();

  static final SettingsController instance = SettingsController._();

  SharedPreferences? _prefs;

  bool _blockSite = false;
  List<String> _sitesToBlock = [];

  bool _enableNotifications = true;
  bool _autoContinue = false;

  int _defaultMinutes = 25;
  int _shortBreakLength = 5;
  int _longBreakLength = 10;

  bool get blockSite => _blockSite;
  List<String> get sitesToBlock => _sitesToBlock;
  bool get enableNotifications => _enableNotifications;
  bool get autoContinue => _autoContinue;
  int get defaultMinutes => _defaultMinutes;
  int get shortBreakLength => _shortBreakLength;
  int get longBreakLength => _longBreakLength;

  SettingsController() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    _defaultMinutes = _prefs!.getInt("defaultMinutes") ?? 25;
    _shortBreakLength = _prefs!.getInt("shortBreakLength") ?? 5;
    _longBreakLength = _prefs!.getInt("longBreakLength") ?? 10;

    _blockSite = _prefs!.getBool("BlockSite") ?? false;
    _sitesToBlock = _prefs!.getStringList("sitesToBlock") ?? [];

    _enableNotifications = _prefs!.getBool("EnableNotifications") ?? true;
    _autoContinue = _prefs!.getBool("AutoContinue") ?? false;

    notifyListeners();
  }

  set blockSite(bool value) {
    if (_blockSite == value) return;
    _blockSite = value;
    _prefs?.setBool("BlockSite", value);
    notifyListeners();
  }

  set sitesToBlock(List<String> value) {
    if (_sitesToBlock == value) return;
    _sitesToBlock = value;
    _prefs?.setStringList("sitesToBlock", value);
    notifyListeners();
  }

  set enableNotifications(bool value) {
    if (_enableNotifications == value) return;
    _enableNotifications = value;
    _prefs?.setBool("EnableNotifications", value);
    notifyListeners();
  }

  set autoContinue(bool value) {
    if (_autoContinue == value) return;
    _autoContinue = value;
    _prefs?.setBool("AutoContinue", value);
    notifyListeners();
  }

  set defaultMinutes(int value) {
    if (_defaultMinutes == value) return;
    _defaultMinutes = value;
    _prefs?.setInt("defaultMinutes", value);
    notifyListeners();
  }

  set shortBreakLength(int value) {
    if (_shortBreakLength == value) return;
    _shortBreakLength = value;
    _prefs?.setInt("shortBreakLength", value);
    notifyListeners();
  }

  set longBreakLength(int value) {
    if (_longBreakLength == value) return;
    _longBreakLength = value;
    _prefs?.setInt("longBreakLength", value);
    notifyListeners();
  }
}
