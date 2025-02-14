const router = require("express").Router();
const UserController = require('../controller/user.controller');

router.post("/api/users/register",UserController.register);

router.post("/login", UserController.login);


module.exports = router;