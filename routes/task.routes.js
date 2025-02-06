const express = require('express');
const router = express.Router();
const TaskController = require('../controller/task.controller');

router.post('/tasks', TaskController.createTask);

router.get('/tasks', TaskController.getTasks);

router.put('/tasks', TaskController.updateTask);

router.delete('/tasks', TaskController.deleteTask);

module.exports = router;
