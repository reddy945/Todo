const router = require("express").Router();
const UserController = require('../controller/user.controller');

router.post("https://todo-o8cx.onrender.com/api/users/register",UserController.register);

router.post("/login", UserController.login);


module.exports = router;