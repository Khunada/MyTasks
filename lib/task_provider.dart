import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TaskProvider with ChangeNotifier {
  final _databaseRef = FirebaseDatabase.instance.ref().child('tasks');
  StreamSubscription? _taskListener;
  User? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get tasks => List.unmodifiable(_tasks);

  TaskProvider() {
    // Awal inisialisasi
    _currentUser = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      _initializeTasks(); // Panggil ulang saat akun berubah
    });
    _initializeTasks();
  }

  // Inisialisasi listener real-time
  void _initializeTasks() {
    final userId = _currentUser?.uid;
    if (userId != null) {
      // Hapus listener lama jika ada
      _taskListener?.cancel();

      // Atur listener baru
      _taskListener = _databaseRef
          .orderByChild('creator')
          .equalTo(userId)
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          _tasks.clear();
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          data.forEach((key, value) {
            final task = Map<String, dynamic>.from(value as Map);
            task['id'] = key;
            _tasks.add(task);
          });
          notifyListeners();
        } else {
          _tasks.clear();
          notifyListeners();
        }
      });
    } else {
      // Jika user tidak login, kosongkan data
      _tasks.clear();
      notifyListeners();
    }
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    final userId = _currentUser?.uid;
    if (userId != null) {
      task['creator'] = userId; // Tambahkan user ID ke task
      await _databaseRef.push().set(task);
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> task) async {
    await _databaseRef.child(taskId).update(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _databaseRef.child(taskId).remove();
  }

  @override
  void dispose() {
    _taskListener?.cancel();
    super.dispose();
  }
}
