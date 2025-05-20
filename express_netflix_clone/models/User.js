const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    birthDate: Date,
    avatar: String,
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    watchLater: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Movie' }],
    favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Movie' }],
    purchasedMovies: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Movie' }],
    preferences: [String],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true },
});

module.exports = mongoose.model('User', userSchema);