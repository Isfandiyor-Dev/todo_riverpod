class Todo {
  String id;
  String task;
  DateTime date;
  bool isDone;

  Todo({
    required this.id,
    required this.task,
    required this.date,
    required this.isDone,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      task: map['task'] ?? '',
      date: DateTime.parse(map['date']),
      isDone: map['isDone'] == 1, // int 1 -> true, 0 -> false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'date': date.toIso8601String(),
      'isDone': isDone ? 1 : 0, // true -> 1, false -> 0
    };
  }

  Map<String, dynamic> toMapFirebase(){ 
    return {
      'id': id,
      'task': task,
      'date': date.toIso8601String(),
      'isDone': isDone,
    };
  }
}
