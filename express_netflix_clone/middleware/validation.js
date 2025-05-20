const { check, validationResult } = require('express-validator');

// Xử lý lỗi xác thực
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, message: errors.array()[0].msg });
    }
    next();
};

// Xác thực đăng ký
const validateRegister = [
    check('username').notEmpty().withMessage('Username là bắt buộc'),
    check('email').isEmail().withMessage('Định dạng email không hợp lệ'),
    check('password')
        .isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự')
        .matches(/[A-Z]/).withMessage('Mật khẩu phải chứa một chữ cái in hoa')
        .matches(/^[a-zA-Z0-9]+$/).withMessage('Mật khẩu không được chứa ký tự đặc biệt'),
    check('confirmPassword')
        .custom((value, { req }) => value === req.body.password)
        .withMessage('Mật khẩu xác nhận không khớp'),
    validate,
];

// Xác thực đăng nhập
const validateLogin = [
    check('identifier').notEmpty().withMessage('Username hoặc email là bắt buộc'),
    check('password').notEmpty().withMessage('Mật khẩu là bắt buộc'),
    validate,
];

// Xác thực cập nhật người dùng
const validateUpdateUser = [
    check('username').optional().notEmpty().withMessage('Username không được để trống'),
    check('password')
        .optional()
        .isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự')
        .matches(/[A-Z]/).withMessage('Mật khẩu phải chứa một chữ cái in hoa')
        .matches(/^[a-zA-Z0-9]+$/).withMessage('Mật khẩu không được chứa ký tự đặc biệt'),
    check('birthDate').optional().isISO8601().withMessage('Định dạng ngày không hợp lệ'),
    validate,
];

// Xác thực tạo/cập nhật thể loại
const validateGenre = [
    check('name').notEmpty().withMessage('Tên thể loại là bắt buộc'),
    validate,
];

// Xác thực tìm kiếm phim
// const validateSearchMovies = [
//     check('title').notEmpty().withMessage('Tiêu đề tìm kiếm là bắt buộc'),
//     validate,
// ];

// Xác thực tạo phim
const validateCreateMovie = [
    check('title').notEmpty().withMessage('Tiêu đề là bắt buộc'),
    check('videoUrl').notEmpty().withMessage('URL video là bắt buộc'),
    check('thumbnail').notEmpty().withMessage('Hình thu nhỏ là bắt buộc'),
    check('genre').notEmpty().withMessage('Thể loại là bắt buộc'),
    check('price').optional().isFloat({ min: 0 }).withMessage('Giá phải là số dương'),
    validate,
];

// Xác thực cập nhật phim
const validateUpdateMovie = [
    check('title').optional().notEmpty().withMessage('Tiêu đề không được để trống'),
    check('videoUrl').optional().notEmpty().withMessage('URL video không được để trống'),
    check('thumbnail').optional().notEmpty().withMessage('Hình thu nhỏ không được để trống'),
    check('genre').optional().notEmpty().withMessage('Thể loại không được để trống'),
    check('price').optional().isFloat({ min: 0 }).withMessage('Giá phải là số dương'),
    validate,
];

// Xác thực thêm comment
const validateCreateComment = [
    check('movieId').notEmpty().withMessage('ID phim là bắt buộc'),
    check('content').notEmpty().withMessage('Nội dung comment là bắt buộc'),
    validate,
];

// Xác thực thêm phim vào danh sách tải về
const validateAddToDownloads = [
    check('movieId').notEmpty().withMessage('ID phim là bắt buộc'),
    validate,
];

module.exports = {
    validateRegister,
    validateLogin,
    validateUpdateUser,
    validateGenre,
    validateCreateMovie,
    validateUpdateMovie,
    validateCreateComment,
    validateAddToDownloads,
};