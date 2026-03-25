import 'dart:convert';
import '../../services/mongo_service.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import './models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  final ValueNotifier<bool> isOffline = ValueNotifier(false);
  static const String _storageKey = 'user_logs_data';

  LogController() {
    loadFromDisk().then((_) {
      fetchLogs();
    });
    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
        case InternetConnectionStatus.slow:
          if (isOffline.value == true) {
            isOffline.value = false;
            print("Internet kembali! Memulai auto-sync...");
            fetchLogs();
          }
          break;
        case InternetConnectionStatus.disconnected:
          isOffline.value = true;
          print("Koneksi internet terputus.");
          break;
      }
    });
  }

  Future<void> fetchLogs() async {
    try {
      await syncOfflineLogs();

      final cloudLogs = await MongoService().getLogs();

      logsNotifier.value = cloudLogs;
      filteredLogs.value = cloudLogs;
      isOffline.value = false;
      await saveToDisk();
    } catch (e) {
      isOffline.value = true; // --- BARU: Gagal tarik data, OFFLINE ---
      print("Gagal mengambil data dari database: $e");
    }
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
      isSynced: false,
    );

    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;
    await saveToDisk();

    await syncOfflineLogs();
  }

  Future<void> syncOfflineLogs() async {
    final unsyncedLogs = logsNotifier.value
        .where((log) => log.isSynced == false)
        .toList();

    if (unsyncedLogs.isEmpty) return;

    try {
      for (var log in unsyncedLogs) {
        await MongoService().insertLog(log);
        log.isSynced = true;
      }
      await saveToDisk();
      isOffline.value = false;

      logsNotifier.value = List.from(logsNotifier.value);
      filteredLogs.value = List.from(filteredLogs.value);

      print("Berhasil sinkronisasi data offline ke Cloud!");
    } catch (e) {
      isOffline.value = true;
      print("Masih offline, sinkronisasi tertunda.");
    }
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc,
    String category,
  ) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
      isSynced: false,
    );

    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;
    await saveToDisk();

    try {
      await MongoService().updateLog(updatedLog);
      updatedLog.isSynced = true;

      logsNotifier.value = List.from(currentLogs);
      filteredLogs.value = List.from(currentLogs);
      await saveToDisk();
      isOffline.value = false;
    } catch (e) {
      isOffline.value = true;
      print("Gagal update ke database: $e");
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final logToDelete = currentLogs[index];

    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;
    await saveToDisk();

    if (logToDelete.id != null) {
      try {
        await MongoService().deleteLog(logToDelete.id!);
        isOffline.value = false;
      } catch (e) {
        isOffline.value = true;
        print("Gagal hapus dari database: $e");
      }
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      logsNotifier.value.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
      filteredLogs.value = logsNotifier.value;
    }
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
