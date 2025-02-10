import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks(); // Fetch tasks when the screen loads
  }

  Future<void> fetchTasks() async {
    try {
      // Replace with your Node.js backend URL
      final response = await http.get(Uri.parse('https://reddy-db2z.onrender.com/api/tasks'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode the JSON response
        setState(() {
          tasks = data; // Assign the tasks from the API response
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load tasks");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching tasks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Task',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchTasks, // Reload tasks
=======
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
>>>>>>> 150071e3df56c85ef76e9c75b3c07cc0ce4c0490
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(child: Text("No tasks available"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              title: task['title'],
              time: task['time'],
              daysLeft: task['daysLeft'],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String daysLeft;

  TaskCard({required this.title, required this.time, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.task, color: Colors.orange, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(time, style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(daysLeft, style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
