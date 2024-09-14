// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/models/todo.dart';
import 'package:todo_riverpod/provider/todo_provider.dart';
import 'package:uuid/uuid.dart';

class TodoHomePage extends ConsumerStatefulWidget {
  const TodoHomePage({super.key});

  @override
  ConsumerState<TodoHomePage> createState() {
    return _TodoHomePageState();
  }
}

class _TodoHomePageState extends ConsumerState<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();

  void _addTodoItem(WidgetRef ref, String task) async {
    final newTodo = Todo(
      id: const Uuid().v1(),
      task: task,
      date: DateTime.now(),
      isDone: false,
    );
    await ref.read(todoNotifierProvider.notifier).addTodo(newTodo);
    _controller.clear();
  }

  void _editTodoItem(WidgetRef ref, Todo todo) async {
    await ref.read(todoNotifierProvider.notifier).editTodo(todo);
  }

  void _deleteTodoItem(WidgetRef ref, String id) async {
    await ref.read(todoNotifierProvider.notifier).deleteTodo(id);
  }

  void _toggleCompletion(WidgetRef ref, Todo todo) async {
    setState(() {
      todo.isDone = !todo.isDone; // checkboxni tezda yangilaymiz
    });

    try {
      await ref.read(todoNotifierProvider.notifier).editTodo(todo);
      // async operatsiya muvaffaqiyatli bo'lganda holatni qayta yuklash
    } catch (e) {
      setState(() {
        todo.isDone = !todo.isDone; // xato bo'lsa qaytarish
      });
      print("Error: $e");
    }
  }

  void _showEditDialog(WidgetRef ref, BuildContext context, Todo todo) {
    TextEditingController editController =
        TextEditingController(text: todo.task);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit ToDo'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Enter new task'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                todo.task = editController.text;
                _editTodoItem(ref, todo);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showMessenger(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        ref.refresh(todoNotifierProvider);
        showMessenger(context, "Internet mavjud emas!", Colors.redAccent);
        showMessenger(context, "Offline rejimga o'tildi!", Colors.orange);
      } else {
        ref.refresh(todoNotifierProvider);
        showMessenger(
            context, "Internetga muvaffaqiyatli ulandi!", Colors.green);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("build");
    final todoState = ref.watch(todoNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
      ),
      body: todoState.when(
        data: (todos) {
          if (todos == null || todos.isEmpty) {
            return const Center(child: Text('No todos yet.'));
          }
          for (var element in todos) {
            print("Bu build ichidagi: ${element.toMapFirebase()}");
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                leading: Checkbox(
                  value: todo.isDone,
                  onChanged: (value) {
                    _toggleCompletion(ref, todo);
                  },
                ),
                title: Text(
                  todo.task,
                  style: TextStyle(
                    decoration: todo.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(ref, context, todo);
                    } else if (value == 'delete') {
                      _deleteTodoItem(ref, todo.id);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 3,
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add ToDo'),
                content: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Enter task'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _addTodoItem(ref, _controller.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
