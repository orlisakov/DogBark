const router = require('express').Router();
const AdminController = require("../controllers/admin_controller");
//--------------------------------------------------------------------------------
router.post('/sendMessageAdminToUser', AdminController.sendMessageAdminToUser);
router.delete('/deleteUserByAdmin', AdminController.deleteUserByAdmin);
router.get('/getTrainers', AdminController.getTrainers);
router.get('/getOwners', AdminController.getOwners);
//--------------------------------------------------------------------------------
router.post('/sendMessageUserToAdmin', AdminController.sendMessageUserToAdmin);

module.exports = router;