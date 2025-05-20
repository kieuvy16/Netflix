const express = require('express');
const router = express.Router();
const genreController = require('../controllers/genreController');
const { validateGenre } = require('../middleware/validation');

//Api
router.get('/', genreController.getAllGenres);
router.get('/:id', genreController.getGenreById);

module.exports = router;