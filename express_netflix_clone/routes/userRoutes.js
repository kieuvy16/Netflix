const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { validateRegister, validateLogin, validateUpdateUser } = require('../middleware/validation');
const { authenticateJWT } = require('../middleware/auth');


//Api
router.post('/register', validateRegister, userController.register);
router.post('/login', validateLogin, userController.login);
router.get('/:id', authenticateJWT, userController.getUserById);
router.put('/:id', validateUpdateUser, userController.updateUser);
router.get('/', userController.getAllUsers);

module.exports = router;