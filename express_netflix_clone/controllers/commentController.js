const mongoose = require('mongoose');
const Comment = require('../models/Comment');

// Thêm comment mới
exports.createComment = async (req, res) => {
    try {
        const { movieId, content } = req.body;
        const userId = req.user.id;

        if (!mongoose.isValidObjectId(movieId)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }

        if (!content || content.trim() === '') {
            return res.status(400).json({ success: false, message: 'Nội dung comment không được để trống' });
        }

        const comment = new Comment({
            user: userId,
            movie: movieId,
            content,
        });

        await comment.save();
        res.status(201).json({ success: true, message: 'Thêm comment thành công', data: comment });
    } catch (error) {
        console.error('Error in createComment:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy danh sách comment của phim
exports.getCommentsByMovie = async (req, res) => {
    try {
        const { movieId } = req.params;

        if (!mongoose.isValidObjectId(movieId)) {
            return res.status(400).json({ success: false, message: 'ID phim không hợp lệ' });
        }

        const comments = await Comment.find({ movie: movieId })
            .populate('user', 'username avatar')
            .sort({ createdAt: -1 });

        res.json({ success: true, data: comments });
    } catch (error) {
        console.error('Error in getCommentsByMovie:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Chỉnh sửa comment
exports.updateComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const { content } = req.body;
        const userId = req.user.id; 

        if (!mongoose.isValidObjectId(commentId)) {
            return res.status(400).json({ success: false, message: 'ID comment không hợp lệ' });
        }

        if (!content || content.trim() === '') {
            return res.status(400).json({ success: false, message: 'Nội dung comment không được để trống' });
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy comment' });
        }

        if (comment.user.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Bạn không có quyền chỉnh sửa comment này' });
        }

        comment.content = content;
        comment.updatedAt = Date.now();
        await comment.save();

        res.json({ success: true, message: 'Chỉnh sửa comment thành công', data: comment });
    } catch (error) {
        console.error('Error in updateComment:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// Xóa comment
exports.deleteComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const userId = req.user.id; 

        if (!mongoose.isValidObjectId(commentId)) {
            return res.status(400).json({ success: false, message: 'ID comment không hợp lệ' });
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy comment' });
        }

        if (comment.user.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Bạn không có quyền xóa comment này' });
        }

        await Comment.findByIdAndDelete(commentId);
        res.json({ success: true, message: 'Xóa comment thành công' });
    } catch (error) {
        console.error('Error in deleteComment:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};