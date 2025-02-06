const express = require('express');
const app = express();

app.use(express.json());

const taskRoutes = require('./routes/task.routes');

app.use('/api', taskRoutes);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ status: false, message: "Internal Server Error" });
});

module.exports = app;
