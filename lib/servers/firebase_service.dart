// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:todo_riverpod/models/todo.dart';

class FirebaseService {
  late final Dio _dio;

  FirebaseService() {
    _dio = Dio(
      BaseOptions(baseUrl: "https://todo-485be-default-rtdb.firebaseio.com/"),
    );
  }

  Future<Map<String, dynamic>?> getTodos() async {
    const String query = "todos.json";
    try {
      final response = await _dio.get(query);
      // print(response);
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      print("Get Todos Dio Exception: ${e.response?.data}");
      throw e.response?.data ?? 'An unexpected error occurred';
    } catch (e) {
      print("Get Todos Error: $e");
      rethrow;
    }
  }

  Future<void> addTodo(Todo todo) async {
    String query = "todos/${todo.id}.json"; // .json kengaytmasi qo'shildi
    try {
      final response = await _dio.put(query, data: todo.toMapFirebase());
      // print(response);
    } on DioException catch (e) {
      print("Add Todo Dio Exception: ${e.response?.data}");
      throw e.response?.data ?? 'An unexpected error occurred';
    } catch (e) {
      print("Add Todo Error: $e");
      rethrow;
    }
  }

  Future<void> editTodo(Todo todo) async {
    final String query = "todos/${todo.id}.json";
    try {
      final response = await _dio.patch(query, data: todo.toMapFirebase());
      // print(response.data);
    } on DioException catch (e) {
      print("Edit Todo Dio Exception: ${e.response?.data}");
      throw e.response?.data ?? 'An unexpected error occurred';
    } catch (e) {
      print("Edit Todo Error: $e");
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    final String query = "todos/$id.json";
    try {
      final response = await _dio.delete(query);
      print(response);
    } on DioException catch (e) {
      print("Delete Todo Dio Exception: ${e.response?.data}");
      throw e.response?.data ?? 'An unexpected error occurred';
    } catch (e) {
      print("Delete Todo Error: $e");
      rethrow;
    }
  }

  Future<void> syncTodos(List<Todo> todos) async {
    try {
      for (final todo in todos) {
        await addTodo(todo); // Har bir todo ni Firebase'ga qo'shish
      }
    } on DioException catch (e) {
      print("Sync Todos Dio Exception: ${e.response?.data}");
      throw e.response?.data ?? 'An unexpected error occurred';
    } catch (e) {
      print("Sync Todos Error: $e");
      rethrow;
    }
  }
}
