import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await MongoDatabase.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _todos = [];
  final String apiUrl = 'https://reddy-db2z.onrender.com/api/tasks';  // Ensure this is correct


  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Fetch tasks
  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _todos.clear();
          _todos.addAll(List<Map<String, dynamic>>.from(data));
        });
      } else {
        _showSnackBar("Failed to fetch tasks: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Error fetching tasks: $e");
    }
  }

  // Add a task
  Future<void> _addTask() async {
    if (_controller.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': _controller.text}),
      );
      if (response.statusCode == 201) {
        setState(() {
          _todos.add(jsonDecode(response.body));
        });
        _controller.clear();
      } else {
        _showSnackBar("Failed to add task");
      }
    } catch (e) {
      _showSnackBar("Error adding task: $e");
    }
  }

  // Toggle task
  Future<void> _toggleTaskCompletion(int index) async {
    final taskId = _todos[index]['_id'];
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$taskId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _todos[index]['completed'] = !_todos[index]['completed'];
        });
      } else {
        _showSnackBar("Failed to update task");
      }
    } catch (e) {
      _showSnackBar("Error updating task: $e");
    }
  }

  // Delete task
  Future<void> _deleteTask(int index) async {
    final taskId = _todos[index]['_id'];
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$taskId'));
      if (response.statusCode == 200) {
        setState(() {
          _todos.removeAt(index);
        });
      } else {
        _showSnackBar("Failed to delete task");
      }
    } catch (e) {
      _showSnackBar("Error deleting task: $e");
    }
  }

  // Show Snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
        backgroundColor: Colors.yellow[400],
      ),
      backgroundColor: Colors.blue[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: 'Enter a task')),
                ),
                IconButton(onPressed: _addTask, icon: Icon(Icons.add))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: _todos[index]['completed'],
                    onChanged: (_) => _toggleTaskCompletion(index),
                  ),
                  title: Text(
                    _todos[index]['title'],
                    style: TextStyle(
                      decoration: _todos[index]['completed']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
