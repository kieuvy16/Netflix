const express = require('express');
const router = express.Router();
const movieController = require('../controllers/movieController');
const { authenticateJWT } = require('../middleware/auth');

//Api
router.get('/', movieController.getAllMovies);
router.get('/:id', movieController.getMovieById);
router.get('/genre/:genreId', movieController.getMoviesByGenre);
router.get('/search', movieController.searchMoviesByTitle);
router.get('/purchasedMovies', authenticateJWT, movieController.getPurchasedMovies);
router.get('/favorites', authenticateJWT,  movieController.getFavorites);
router.post('/favorites', authenticateJWT,  movieController.addToFavorites);
router.delete('/favorites/:movieId', authenticateJWT,  movieController.removeFromFavorites);
router.post('/payment/:movieId', authenticateJWT, movieController.purchaseMovie);

module.exports = router;