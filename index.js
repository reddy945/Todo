const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = express();
const PORT = 5000; // Change the port if needed
const JWT_SECRET =
  "4dbe1fe04049a5cbaaf07edc30ef3ca68c4febf712c455fb46ed8d870107d9d1a464bd0bcf3095104da6cfda9576cc927f9ece36c7fd06a57226928660b5458a"; // Replace with a secure secret

const MONGO_URI =
  "mongodb+srv://Reddyxr:6y7XLhP6aUs4fJlB@reddy.u65sc.mongodb.net/?retryWrites=true&w=majority&appName=Reddy";

// MongoDB Connection
mongoose
  .connect(MONGO_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("Failed to connect to MongoDB", err));

// Middleware
app.use(cors());
app.use(bodyParser.json());

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

  const hashedPassword = await bcrypt.hash(password, 10);

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
    res.status(500).json({ error: "Error registering user" });
  }
});

// User Login
app.post("/api/users/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email and password are required" });
  }

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
    res.status(500).json({ error: "Error adding task" });
  }
});

// Get All Tasks
app.get("/tasks", authenticate, async (req, res) => {
  try {
    const tasks = await Task.find({ userId: req.userId });
    res.status(200).json(tasks);
  } catch (err) {
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
    res.status(500).json({ error: "Error deleting task" });
  }
});

// Start the Server
app.listen(PORT, "0.0.0.0", () => {
  const renderURL = "https://todo-ntim.onrender.com";
  console.log(`Server running on ${renderURL}/tasks`);
  console.log(`Server running on ${renderURL}/api/users/register`);
  console.log(`Server running on ${renderURL}/api/users/login`);
});
