const mongoose = require('mongoose');

const downloadSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    movie: { type: mongoose.Schema.Types.ObjectId, ref: 'Movie', required: true },
    downloadedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Download', downloadSchema);