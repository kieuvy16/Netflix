const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const genreController = require('../controllers/genreController');
const movieController = require('../controllers/movieController');
const adminController = require('../controllers/adminController');
const { validateUpdateUser, validateGenre, validateCreateMovie, validateUpdateMovie } = require('../middleware/validation');

//Api
router.get('/api/users', userController.getAllUsers);
router.get('/api/user/:id', userController.getUserById);
router.get('/api/user/deactivated', userController.getDeactivatedUsers);
router.put('/api/user/:id', validateUpdateUser, userController.updateUser);
router.put('/api/user/toggle/:id', userController.toggleUserStatus);

router.get('/api/genres', genreController.getAllGenres);
router.post('/api/genre', validateGenre, genreController.createGenre);
router.put('/api/genre/:id', validateGenre, genreController.updateGenre);
router.delete('/api/genre/:id', genreController.deleteGenre);

router.get('/api/movies', movieController.getAllMovies);
router.get('/api/movie/search', movieController.searchMoviesByTitle);
router.post('/api/movie', validateCreateMovie, movieController.createMovie);
router.put('/api/movie/:id', validateUpdateMovie, movieController.updateMovie);
router.delete('/api/movie/:id', movieController.deleteMovie);

//Render
router.get('/', adminController.getAdmin);
router.get('/movie', adminController.getManageMovies);
router.get('/movie/create', adminController.getManageCreateMovie);
router.get('/movie/update', adminController.getManageUpdateMovie);
router.get('/genre', adminController.getManageGenres);
router.get('/genre/create', adminController.getManageCreateGenre);
router.get('/genre/update', adminController.getManageUpdateGenre);
router.get('/user', adminController.getManageUser);
router.get('/user/update', adminController.getManageUpdateUser);
router.get('/movie/comment', adminController.getManageCommentMovie);


module.exports = router;