const mongoose = require('mongoose');
const Genre = require('../models/Genre');
const { validationResult } = require('express-validator');

// Lấy tất cả genre
exports.getAllGenres = async (req, res) => {
    try {
        const genres = await Genre.find({});
        res.json({ success: true, data: genres });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy genre theo ID
exports.getGenreById = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid genre ID' });
        }

        const genre = await Genre.findById(req.params.id);
        if (!genre) {
            return res.status(404).json({ success: false, message: 'Genre not found' });
        }
        res.json({ success: true, data: genre });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Tạo mới genre
exports.createGenre = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ success: false, message: errors.array()[0].msg });
        }

        const { name } = req.body;
        const genre = new Genre({ name });
        await genre.save();
        res.status(201).json({ success: true, data: genre });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, message: 'Genre name already exists' });
        }
        res.status(500).json({ success: false, message: error.message });
    }
};

// Cập nhập genre
exports.updateGenre = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid genre ID' });
        }

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ success: false, message: errors.array()[0].msg });
        }

        const { name } = req.body;
        const genre = await Genre.findByIdAndUpdate(
            req.params.id,
            { name, updatedAt: Date.now() },
            { new: true }
        );
        if (!genre) {
            return res.status(404).json({ success: false, message: 'Genre not found' });
        }
        res.json({ success: true, data: genre });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, message: 'Genre name already exists' });
        }
        res.status(500).json({ success: false, message: error.message });
    }
};

// Xóa genre
exports.deleteGenre = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'Invalid genre ID' });
        }

        const genre = await Genre.findByIdAndDelete(req.params.id);
        if (!genre) {
            return res.status(404).json({ success: false, message: 'Genre not found' });
        }
        res.json({ success: true, message: 'Genre deleted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};