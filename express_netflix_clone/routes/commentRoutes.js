const express = require('express');
const router = express.Router();
const commentController = require('../controllers/commentController');
const { authenticateJWT } = require('../middleware/auth');

// API
router.post('/', authenticateJWT, commentController.createComment);
router.get('/movie/:movieId', commentController.getCommentsByMovie); 
router.put('/:commentId', authenticateJWT, commentController.updateComment); 
router.delete('/:commentId', authenticateJWT, commentController.deleteComment); 

module.exports = router;