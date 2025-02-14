const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config(); // Load environment variables from .env file
const app = express();
const PORT = process.env.PORT || 5000; // Use PORT from .env or default to 5000
const JWT_SECRET = process.env.JWT_SECRET;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Connect to MongoDB
mongoose.set("strictQuery", false); // Suppress deprecation warning
mongoose
  .connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("Failed to connect to MongoDB", err));

// MongoDB Schemas
const userSchema = new mongoose.Schema({
  name: String,
  email: String,
  mobile: String,
  password: String,
});

const taskSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  title: String,
  time: String,
  duration: String,
});

const User = mongoose.model("User", userSchema);
const Task = mongoose.model("Task", taskSchema);

// User Registration
app.post("/api/users/register", async (req, res) => {
  const { name, email, mobile, password } = req.body;

  if (!name || !password || (!email && !mobile)) {
    return res.status(400).json({ error: "All fields are required" });
  }

  const hashedPassword = await bcrypt.hash(password, 12); // Updated saltRounds to 12 for better security

  try {
    const user = new User({
      name,
      email,
      mobile,
      password: hashedPassword,
    });

    await user.save();
    res.status(201).json({ message: "User registered successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error registering user" });
  }
});

// User Login
app.post("/api/users/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email and password are required" });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: "1h" });
    res.status(200).json({ message: "Login successful", token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error during login" });
  }
});

// Middleware for Authentication
const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ error: "Access denied" });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
    next();
  } catch (err) {
    res.status(403).json({ error: "Invalid token" });
  }
};

// Add Task
app.post("/tasks", authenticate, async (req, res) => {
  const { title, time, duration } = req.body;

  if (!title || !time || !duration) {
    return res.status(400).json({ error: "All fields are required" });
  }

  try {
    const task = new Task({
      userId: req.userId,
      title,
      time,
      duration,
    });

    await task.save();
    res.status(201).json({ message: "Task added successfully", task });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error adding task" });
  }
});

// Get All Tasks
app.get("/tasks", authenticate, async (req, res) => {
  try {
    const tasks = await Task.find({ userId: req.userId });
    res.status(200).json(tasks);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error fetching tasks" });
  }
});

// Delete Task
app.delete("/tasks/:id", authenticate, async (req, res) => {
  const { id } = req.params;

  try {
    await Task.findByIdAndDelete(id);
    res.status(200).json({ message: "Task deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error deleting task" });
  }
});

// Get Current User (Optional)
app.get("/api/users/me", authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select("-password");
    res.status(200).json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error fetching user details" });
  }
});

// Start the Server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on https://todo-o8cx.onrender.com`);
});