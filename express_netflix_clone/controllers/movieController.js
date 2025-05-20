const mongoose = require('mongoose');
const Movie = require('../models/Movie');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

// Lấy tất cả movie
exports.getAllMovies = async (req, res) => {
    try {
        const movies = await Movie.find({}).populate('genre');
        res.json({ success: true, data: movies });
    } catch (error) {
        console.error('Error in getAllMovies:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy movie theo ID
exports.getMovieById = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }

        const movie = await Movie.findById(req.params.id).populate('genre');
        if (!movie) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy phim' });
        }
        res.json({ success: true, data: movie });
    } catch (error) {
        console.error('Error in getMovieById:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy movie theo genre
exports.getMoviesByGenre = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.genreId)) {
            return res.status(400).json({ success: false, message: 'ID thể loại không hợp lệ' });
        }

        const movies = await Movie.find({ genre: req.params.genreId }).populate('genre');
        res.json({ success: true, data: movies });
    } catch (error) {
        console.error('Error in getMoviesByGenre:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Tìm kiếm movie
exports.searchMoviesByTitle = async (req, res) => {
    try {
        const { title } = req.query;

        if (!title || title.trim() === '') {
            return res.json({ success: true, data: [] });
        }

        const escapedTitle = title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

        const movies = await Movie.find({ 
            title: { $regex: escapedTitle, $options: 'i' } 
        }).populate('genre');
        res.json({ success: true, data: movies });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Tạo phim mới
exports.createMovie = async (req, res) => {
    try {
        const { title, description, videoUrl, thumbnail, genre, isPaid, price } = req.body;

        if (!mongoose.isValidObjectId(genre)) {
            return res.status(400).json({ success: false, message: 'ID thể loại không hợp lệ' });
        }

        const movie = new Movie({
            title,
            description,
            videoUrl,
            thumbnail,
            genre,
            isPaid: isPaid || false,
            price: isPaid ? price : 0,
        });

        await movie.save();
        res.status(201).json({ success: true, data: movie });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Cập nhật movie
exports.updateMovie = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }

        const { title, description, videoUrl, thumbnail, genre, isPaid, price } = req.body;
        const updates = { updatedAt: Date.now() };
        if (title) updates.title = title;
        if (description) updates.description = description;
        if (videoUrl) updates.videoUrl = videoUrl;
        if (thumbnail) updates.thumbnail = thumbnail;
        if (genre) {
            if (!mongoose.isValidObjectId(genre)) {
                return res.status(400).json({ success: false, message: 'ID thể loại không hợp lệ' });
            }
            updates.genre = genre;
        }
        if (isPaid !== undefined) updates.isPaid = isPaid;
        if (price !== undefined) updates.price = isPaid ? price : 0;

        const movie = await Movie.findByIdAndUpdate(req.params.id, updates, { new: true }).populate('genre');
        if (!movie) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy phim' });
        }
        res.json({ success: true, data: movie });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Xóa movie
exports.deleteMovie = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }

        const movie = await Movie.findByIdAndDelete(req.params.id);
        if (!movie) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy phim' });
        }
        res.json({ success: true, message: 'Phim đã được xóa thành công' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy danh sách Movie đã mua của người dùng đang truy cập
exports.getPurchasedMovies = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).populate('purchasedMovies');
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }
        res.json({ success: true, data: user.purchasedMovies });
    } catch (error) {
        console.error('Error in getPurchasedMovies:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy danh sách Movie yêu thích của người dùng đang truy cập
exports.getFavorites = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        if (!user) {
            console.log('User not found:', req.user.id);
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        const validFavorites = user.favorites.filter(id => mongoose.isValidObjectId(id));
        if (validFavorites.length !== user.favorites.length) {
            console.log('Invalid movie IDs found in favorites:', user.favorites);
            user.favorites = validFavorites;
            await user.save();
        }

        if (validFavorites.length === 0) {
            console.log('No valid favorites found for user:', req.user.id);
            return res.json({ success: true, data: [] });
        }

        const movies = await Movie.find({ _id: { $in: validFavorites } }).populate('genre');
        if (movies.length < validFavorites.length) {
            console.log('Some movies not found in favorites:', {
                userId: req.user.id,
                missingIds: validFavorites.filter(id => !movies.some(movie => movie._id.equals(id)))
            });
            user.favorites = movies.map(movie => movie._id);
            await user.save();
        }

        res.json({ success: true, data: movies });
    } catch (error) {
        console.error('Error in getFavorites:', error);
        res.status(500).json({ success: false, message: 'Lỗi server: ' + error.message });
    }
};

// Thêm Movie vào danh sách yêu thích
exports.addToFavorites = async (req, res) => {
    try {
        const { movieId } = req.body;
        if (!mongoose.isValidObjectId(movieId)) {
            console.log('Invalid movieId:', movieId);
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }
        const user = await User.findById(req.user.id);
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }
        if (user.favorites.includes(movieId)) {
            return res.status(400).json({ success: false, message: 'Phim đã có trong danh sách yêu thích' });
        }
        // Kiểm tra phim có tồn tại
        const movie = await Movie.findById(movieId);
        if (!movie) {
            console.log('Movie not found:', movieId);
            return res.status(404).json({ success: false, message: 'Không tìm thấy phim' });
        }
        user.favorites.push(movieId);
        await user.save();
        res.json({ success: true, message: 'Đã thêm phim vào danh sách yêu thích' });
    } catch (error) {
        console.error('Error in addToFavorites:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Xóa movie khỏi danh sách yêu thích
exports.removeFromFavorites = async (req, res) => {
    try {
        const { movieId } = req.params;
        if (!mongoose.isValidObjectId(movieId)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }
        const user = await User.findById(req.user.id);
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }
        const index = user.favorites.indexOf(movieId);
        if (index === -1) {
            return res.status(400).json({ success: false, message: 'Phim không có trong danh sách yêu thích' });
        }
        user.favorites.splice(index, 1);
        await user.save();
        res.json({ success: true, message: 'Đã xóa phim khỏi danh sách yêu thích' });
    } catch (error) {
        console.error('Error in removeFromFavorites:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Thanh toán
exports.purchaseMovie = async (req, res) => {
    try {
        const userId = req.body.userId; 
        const movieId = req.params.movieId;

        if (!mongoose.isValidObjectId(userId) || !mongoose.isValidObjectId(movieId)) {
            return res.status(400).json({ success: false, message: 'ID người dùng hoặc phim không hợp lệ' });
        }

        const user = await User.findById(userId);
        const movie = await Movie.findById(movieId);

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }
        if (!movie) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy phim' });
        }

        if (!movie.isPaid) {
            return res.status(400).json({ success: false, message: 'Phim này không yêu cầu thanh toán' });
        }

        if (user.purchasedMovies.includes(movieId)) {
            return res.status(400).json({ success: false, message: 'Bạn đã mua phim này rồi' });
        }

        // Lưu giao dịch
        const transaction = new Transaction({
            user: userId,
            movie: movieId,
            amount: movie.price,
            status: 'completed',
        });
        await transaction.save();

        // Thêm phim vào danh sách đã mua
        user.purchasedMovies.push(movieId);
        user.updatedAt = Date.now();
        await user.save();

        res.json({ success: true, message: 'Mua phim thành công', data: { purchasedMovies: user.purchasedMovies, transaction } });
    } catch (error) {
        console.error('Error in purchaseMovie:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};