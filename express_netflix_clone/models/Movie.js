const mongoose = require('mongoose');

const movieSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: String,
    videoUrl: { type: String, required: true },
    thumbnail: { type: String, required: true },
    genre: { type: mongoose.Schema.Types.ObjectId, ref: 'Genre', required: true },
    isPaid: { type: Boolean, default: false },
    price: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Movie', movieSchema);