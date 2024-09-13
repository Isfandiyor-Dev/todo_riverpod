// ignore_for_file: avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todo_riverpod/models/todo.dart';
import 'package:todo_riverpod/servers/firebase_service.dart';
import 'package:todo_riverpod/servers/local_database.dart';

class TodoRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final LocalDatabase _localDatabase = LocalDatabase();
  final Connectivity _connectivity = Connectivity();

  Future<List<Todo>?> getTodos() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Internet mavjud emas, SQflite'dan olish
        final data = await _localDatabase.getTodos();
        return data;
      } else {
        // Internet mavjud, Firebase'dan olish
        final data = await _firebaseService.getTodos();
        final todos = data?.entries.map((e) {
          final todo = e.value as Map<String, dynamic>;
          todo["id"] = e.key;
          return Todo.fromMap(todo);
        }).toList();

        if (todos != null) {
          for (final todo in todos) {
            await _localDatabase.insertTodo(todo);
          }
        }

        return todos;
      }
    } catch (e) {
      print("Get Todos Error: $e");
      rethrow;
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Internet mavjud emas, SQflite'da saqlash
        await _localDatabase.insertTodo(todo);
      } else {
        // Internet mavjud, Firebase'da saqlash
        await _firebaseService.addTodo(todo);
        await _localDatabase.insertTodo(todo); // Mahalliy saqlash
      }
    } catch (e) {
      print("Add Todo Error: $e");
      rethrow;
    }
  }

  Future<void> editTodo(Todo todo) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Internet mavjud emas, SQflite'da yangilash
        await _localDatabase.updateTodo(todo);
      } else {
        // Internet mavjud, Firebase'da yangilash
        await _firebaseService.editTodo(todo);
        await _localDatabase.updateTodo(todo); // Mahalliy yangilash
      }
    } catch (e) {
      print("Edit Todo Error: $e");
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Internet mavjud emas, SQflite'da o'chirish
        await _localDatabase.deleteTodo(id);
      } else {
        // Internet mavjud, Firebase'da o'chirish
        await _firebaseService.deleteTodo(id);
        await _localDatabase.deleteTodo(id); // Mahalliy o'chirish
      }
    } catch (e) {
      print("Delete Todo Error: $e");
      rethrow;
    }
  }
}
