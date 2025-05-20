const mongoose = require('mongoose');
const Download = require('../models/Download');
const User = require('../models/User');
const Movie = require('../models/Movie');

// Thêm phim vào danh sách tải
exports.addToDownloads = async (req, res) => {
    try {
        const { movieId } = req.body;
        const userId = req.user.id;

        if (!mongoose.isValidObjectId(movieId)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }

        const user = await User.findById(userId);
        const movie = await Movie.findById(movieId);

        if (!user || !movie) {
            return res.status(404).json({ success: false, message: 'Người dùng hoặc phim không tồn tại' });
        }

        if (movie.isPaid && !user.purchasedMovies.includes(movieId)) {
            return res.status(403).json({ success: false, message: 'Bạn cần mua phim trước khi tải' });
        }

        const existingDownload = await Download.findOne({ user: userId, movie: movieId });
        if (existingDownload) {
            return res.status(400).json({ success: false, message: 'Phim đã có trong danh sách tải về' });
        }

        const download = new Download({
            user: userId,
            movie: movieId,
        });

        await download.save();
        res.json({ success: true, message: 'Thêm phim vào danh sách tải về thành công', data: download });
    } catch (error) {
        console.error('Error in addToDownloads:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy danh sách phim đã tải 
exports.getUserDownloads = async (req, res) => {
    try {
        const userId = req.user.id;

        const downloads = await Download.find({ user: userId })
            .populate('movie')
            .sort({ downloadedAt: -1 });

        res.json({ success: true, data: downloads });
    } catch (error) {
        console.error('Error in getUserDownloads:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};