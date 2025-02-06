const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type']
}));

const PORT = process.env.PORT || 5000;

// Update MongoDB connection string to use environment variable
const mongoURI = process.env.MONGO_URI || 'mongodb+srv://Reddyxr:6y7XLhP6aUs4fJlB@todoproject.u65sc.mongodb.net/?retryWrites=true&w=majority&appName=ToDoProject'; // fallback to local if no env var is set

mongoose.connect(mongoURI)
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch((error) => {
    console.error('Error connecting to MongoDB:', error);
  });

// Task schema
const taskSchema = new mongoose.Schema({
  title: { type: String, required: true },
  completed: { type: Boolean, default: false },
});

const Task = mongoose.model('Task', taskSchema);

app.get('/api/tasks', async (req, res) => {
  try {
    const tasks = await Task.find();
    res.status(200).json(tasks);
  } catch (error) {
    console.error("Error fetching tasks:", error);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

app.post('/api/tasks', async (req, res) => {
  const { title } = req.body;

  if (!title) {
    return res.status(400).json({ error: 'Title is required' });
  }

  try {
    const newTask = new Task({ title });
    await newTask.save();
    res.status(201).json(newTask);
  } catch (error) {
    console.error("Error inserting task:", error);
    res.status(500).json({ error: 'Failed to add task' });
  }
});

app.put('/api/tasks/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const task = await Task.findById(id);

    if (!task) {
      return res.status(404).json({ error: 'Task not found' });
    }

    task.completed = !task.completed; 
    await task.save();

    res.status(200).json(task);
  } catch (error) {
    console.error("Error updating task:", error);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

app.delete('/api/tasks/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deletedTask = await Task.findByIdAndDelete(id);

    if (!deletedTask) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.status(200).json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://localhost:${PORT}/api/tasks`);
});
