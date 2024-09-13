/* whenever a user hits any API so the routes folder will get activated that is our API and it will call our controller */

const router = require('express').Router();
const UserController = require("../controllers/user_controller");

router.post('/registeration', UserController.register);
router.post('/login', UserController.login);

module.exports = router;