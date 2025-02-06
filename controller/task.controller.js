const Task = require('../model/task.model');


exports.createTask = async (req, res) => {
  try {
    const { title, description } = req.body;


    if (!title) {
      return res.status(400).json({ status: false, message: "Title is required" });
    }

    // Create a new task
    const newTask = new Task({ title, description });
    await newTask.save();
    
    // Send response with the created task
    res.status(201).json({ status: true, message: "Task created successfully", task: newTask });
  } catch (error) {
    // Handle errors and send a response
    res.status(500).json({ status: false, message: error.message });
  }
};

// Get all tasks
exports.getTasks = async (req, res) => {
  try {
    const tasks = await Task.find();
    res.status(200).json({ status: true, tasks });
  } catch (error) {
    res.status(500).json({ status: false, message: error.message });
  }
};

// Update a task by ID
exports.updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, completed } = req.body;

    // Validation for title field
    if (!title) {
      return res.status(400).json({ status: false, message: "Title is required" });
    }

    // Update the task
    const updatedTask = await Task.findByIdAndUpdate(id, { title, description, completed }, { new: true });
    
    // If task is not found, send a 404 response
    if (!updatedTask) {
      return res.status(404).json({ status: false, message: "Task not found" });
    }

    res.status(200).json({ status: true, message: "Task updated successfully", task: updatedTask });
  } catch (error) {
    res.status(500).json({ status: false, message: error.message });
  }
};

// Delete a task by ID
exports.deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    // Find and delete the task
    const deletedTask = await Task.findByIdAndDelete(id);
    
    // If task is not found, send a 404 response
    if (!deletedTask) {
      return res.status(404).json({ status: false, message: "Task not found" });
    }

    res.status(200).json({ status: true, message: "Task deleted successfully" });
  } catch (error) {
    res.status(500).json({ status: false, message: error.message });
  }
};
