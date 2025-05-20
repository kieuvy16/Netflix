const jwt = require('jsonwebtoken');

const JWT_SECRET = '1c425abcde67345ab845abchj45a7ck3b9';

// Middleware xác thực JWT
const authenticateJWT = (req, res, next) => {
    let token = req.headers.authorization?.split(' ')[1];

    if (!token && req.cookies && req.cookies.token) {
        token = req.cookies.token;
    }

    if (!token) {
        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.status(401).json({ success: false, message: 'Không có token được cung cấp' });
        }
        
        if (req.session) {
            req.session.errorMessage = 'Vui lòng đăng nhập lại';
        }
        return res.redirect('/');
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            if (req.headers.accept && req.headers.accept.includes('application/json')) {
                return res.status(403).json({ success: false, message: 'Token không hợp lệ hoặc đã hết hạn' });
            }
            
            if (req.session) {
                req.session.errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
            }
            return res.redirect('/');
        }
        req.user = user;
        next();
    });
};

// Middleware giới hạn quyền truy cập
const restrictToAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        // Kiểm tra nếu là yêu cầu API
        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.status(403).json({ success: false, message: 'Truy cập bị từ chối: Chỉ dành cho admin' });
        }
        
        if (req.session) {
            req.session.errorMessage = 'Bạn không có quyền truy cập trang này';
        }
        return res.redirect('/');
    }
    next();
};

module.exports = { authenticateJWT, restrictToAdmin };