import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  int get value => _counter;
  List<List<String>> tracker_list = [];
  List<String> tracked_list = [];

  Future<void> loadInitialData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('last_counter_$username') ?? 0;
    tracked_list = prefs.getStringList('history_$username') ?? [];
  }

  Future<void> increment(String username) async {
    _counter += _step;
    await update_list("Increment", username);
  }

  Future<void> decrement(String username) async {
    if (_counter > 0) _counter -= _step;
    await update_list("Decrement", username);
  }

  Future<void> reset(String username) async {
    _counter = 0;
    _step = 1;
    await update_list("Reset", username);
  }

  void setStep(int step) {
    if (step > 0) {
      _step = step;
    }
  }

  Future<void> update_list(String action, String username) async {
    final time = DateTime.now().toLocal().toString().substring(11, 19);
    String logMessage = "User $username: $action at $time";

    tracked_list.insert(0, logMessage);

    if (tracked_list.length > 5) {
      tracked_list.removeLast();
    }

    if (action == "Reset") {
      tracker_list.add(List.from(tracked_list));
      tracked_list.clear();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter_$username', _counter);
    await prefs.setStringList('history_$username', tracked_list);
  }
}
