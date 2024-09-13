import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_riverpod/models/todo.dart';
import 'package:todo_riverpod/repository/todo_repository.dart';

part 'todo_provider.g.dart';

@riverpod
class TodoNotifier extends _$TodoNotifier {
  final _todoRepository = TodoRepository();

  @override
  Future<List<Todo>?> build() async => _todoRepository.getTodos();

  Future<void> addTodo(Todo todo) async {
    await _todoRepository.addTodo(todo);
    ref.invalidateSelf();
    await future;
  }

  Future<void> editTodo(Todo todo) async {
    await _todoRepository.editTodo(todo);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTodo(String id) async {
    await _todoRepository.deleteTodo(id);
    ref.invalidateSelf();
    await future;
  }
}
