const mongoose = require('mongoose');
const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = '1c425abcde67345ab845abchj45a7ck3b9'; 

// Đăng ký 
exports.register = async (req, res) => {
    try {
        if (req.body.role === 'admin') {
            return res.status(403).json({ success: false, message: 'Không thể tạo tài khoản admin qua API này' });
        }

        const { username, email, password, birthDate, avatar } = req.body;

        const existingUser = await User.findOne({ $or: [{ username }, { email }] });
        if (existingUser) {
            return res.status(400).json({ success: false, message: 'Username hoặc email đã tồn tại' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = new User({
            username,
            email,
            password: hashedPassword,
            birthDate,
            avatar,
            role: 'user',
        });

        await user.save();
        res.status(201).json({ success: true, message: 'Đăng ký người dùng thành công' });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, message: 'Username hoặc email đã tồn tại' });
        }
        res.status(500).json({ success: false, message: error.message });
    }
};

// Đăng nhập
exports.login = async (req, res) => {
    try {
        const { identifier, password } = req.body;
        const user = await User.findOne({
            $or: [{ username: identifier }, { email: identifier }],
        });

        if (!user) {
            return res.status(400).json({ success: false, message: 'Tài khoản không tồn tại' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ success: false, message: 'Mật khẩu không đúng' });
        }

        if (!user.isActive) {
            return res.status(403).json({ success: false, message: 'Tài khoản đã bị vô hiệu hóa' });
        }

        // Tạo token
        const token = jwt.sign(
            { id: user._id, role: user.role },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.status(200).json({
            success: true,
            data: {
                token,
                user: {
                    id: user._id,
                    username: user.username,
                    email: user.email,
                    role: user.role, 
                },
            },
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy user theo ID
exports.getUserById = async (req, res) => {
    try {
        console.log(`Fetching user with ID: ${req.params.id}, Token: ${req.headers.authorization}`);

        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'ID người dùng không hợp lệ' });
        }

        if (!req.user) {
            return res.status(401).json({ success: false, message: 'Yêu cầu xác thực' });
        }

        if (req.user.role !== 'admin' && req.user.id !== req.params.id) {
            return res.status(403).json({ success: false, message: 'Truy cập bị từ chối' });
        }

        const user = await User.findById(req.params.id).select('-password');
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        res.status(200).json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Lỗi máy chủ: ' + error.message });
    }
};

// Update user
exports.updateUser = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'ID người dùng không hợp lệ' });
        }

        const { username, avatar, birthDate, password } = req.body;
        const updates = { updatedAt: Date.now() };
        if (username) updates.username = username;
        if (avatar) updates.avatar = avatar;
        if (birthDate) updates.birthDate = birthDate;
        if (password) {
            updates.password = await bcrypt.hash(password, 10);
        }

        const user = await User.findByIdAndUpdate(req.params.id, updates, { new: true }).select('-password');
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }
        res.json({ success: true, data: user });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, message: 'Username hoặc email đã tồn tại' });
        }
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy danh sách tất cả user
exports.getAllUsers = async (req, res) => {
    try {
        const { role } = req.query;
        const filter = {};
        if (role) {
            filter.role = role;
        }
        const users = await User.find(filter).select('-password');
        res.json({ success: true, data: users });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Chuyển đổi trạng thái user
exports.toggleUserStatus = async (req, res) => {
    try {
        if (!mongoose.isValidObjectId(req.params.id)) {
            return res.status(400).json({ success: false, message: 'ID người dùng không hợp lệ' });
        }

        const { isActive } = req.body;
        if (typeof isActive !== 'boolean') {
            return res.status(400).json({ success: false, message: 'Trạng thái isActive phải là boolean' });
        }

        const user = await User.findByIdAndUpdate(
            req.params.id,
            { isActive, updatedAt: Date.now() },
            { new: true }
        );
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        const message = isActive ? 'Người dùng đã được kích hoạt lại thành công' : 'Người dùng đã bị vô hiệu hóa thành công';
        res.json({ success: true, message, data: { isActive: user.isActive } });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy danh sách user đã vô hiệu hóa
exports.getDeactivatedUsers = async (req, res) => {
    try {
        const users = await User.find({ isActive: false }).select('-password');
        res.json({ success: true, data: users });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};


