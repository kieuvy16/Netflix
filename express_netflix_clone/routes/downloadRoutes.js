const express = require('express');
const router = express.Router();
const downloadController = require('../controllers/downloadController');
const { authenticateJWT } = require('../middleware/auth');

// API
router.post('/', authenticateJWT, downloadController.addToDownloads);
router.get('/', authenticateJWT, downloadController.getUserDownloads); 

module.exports = router;