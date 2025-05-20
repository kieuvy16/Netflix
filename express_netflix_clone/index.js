const express = require('express');
const app = express();
const path = require('path');
const mongoose = require('mongoose');
const UserRoutes = require('./routes/userRoutes');
const CategoryRoutes = require('./routes/genreRoutes');
const AdminRoutes = require('./routes/adminRoutes');
const MovieRoutes = require('./routes/movieRoutes');
const CommentRoutes = require('./routes/commentRoutes');
const DownloadRoutes = require('./routes/downloadRoutes');
const BodyParser = require('body-parser');
const cors = require('cors');
const fs = require('fs');
const multipart = require('connect-multiparty');
const multipartMiddleware = multipart();
const { authenticateJWT, restrictToAdmin } = require('./middleware/auth');
const bcrypt = require('bcrypt');
const User = require('./models/User');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const MongoStore = require('connect-mongo');

const port = process.env.PORT || 8008;
const db = process.env.MONGO_URI || 'mongodb+srv://root:12345@netflixappclone.l9csnyi.mongodb.net/?retryWrites=true&w=majority&appName=NetflixAppClone';

app.set("view engine", "ejs");
app.set("views", "./views");

app.use(cors({ origin: '*' }));
app.use(express.static('public'));
app.use('/images', express.static(path.join(__dirname, 'public/images')));
app.use(BodyParser.json());
app.use(BodyParser.urlencoded({ extended: true }));
app.use(cookieParser());

// Cấu hình express-session
app.use(session({
    secret: process.env.SESSION_SECRET || '1c425abcde67345ab845abchj45a7ck3b9',
    resave: false,
    saveUninitialized: false,
    store: MongoStore.create({
        mongoUrl: db,
        collectionName: 'sessions',
        ttl: 24 * 60 * 60 
    }),
    cookie: {
        secure: process.env.NODE_ENV === 'production',
        maxAge: 24 * 60 * 60 * 1000
    }
}));

// Route cho trang đăng nhập
app.get('/', (req, res) => {
    res.render('login');
});

// Route trang admin với xác thực và kiểm tra quyền
app.get('/admin', authenticateJWT, restrictToAdmin, (req, res) => {
    res.render('admin-page');
});

// Các route API
app.use('/api/user', UserRoutes);
app.use('/api/movie', MovieRoutes);
app.use('/api/genre', CategoryRoutes);
app.use('/api/comments', CommentRoutes);
app.use('/api/downloads', DownloadRoutes);
app.use('/admin', authenticateJWT, restrictToAdmin, AdminRoutes);

// Route xử lý upload file
app.post('/uploadfile', multipartMiddleware, (req, res) => {
    try {
        if (!req.files.upload) {
            return res.status(400).json({ success: false, message: 'Không có file được tải lên' });
        }
        fs.readFile(req.files.upload.path, function (err, data) {
            if (err) {
                return res.status(500).json({ success: false, message: 'Lỗi khi đọc file' });
            }
            const newPath = path.join(__dirname, 'public/images/images-content', req.files.upload.name);
            fs.writeFile(newPath, data, function (err) {
                if (err) {
                    return res.status(500).json({ success: false, message: 'Lỗi khi lưu file' });
                }
                const fileName = req.files.upload.name;
                const url = `/images/images-content/${fileName}`;
                const msg = 'Tải lên thành công';
                const funcNum = req.query.CKEditorFuncNum;
                res.status(201).send(`<script>window.parent.CKEDITOR.tools.callFunction('${funcNum}','${url}','${msg}');</script>`);
            });
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Middleware xử lý lỗi 404
app.use((req, res, next) => {
    console.log(`404 Not Found: ${req.method} ${req.originalUrl}`);
    res.status(404).json({ success: false, message: 'Không tìm thấy tài nguyên' });
});

// Middleware xử lý lỗi toàn cục
app.use((err, req, res, next) => {
    console.error(`Server error: ${err.stack}`);
    res.status(500).json({ success: false, message: 'Lỗi server nội bộ: ' + err.message });
});

const connectDatabase = async () => {
    try {
        await mongoose.connect(db, { useNewUrlParser: true, useUnifiedTopology: true });
        console.log("Kết nối cơ sở dữ liệu thành công");

        const adminExists = await User.findOne({ role: 'admin' });
        if (!adminExists) {
            const hashedPassword = await bcrypt.hash('Admin123', 10);
            const adminUser = new User({
                username: 'admin',
                email: 'admin@gmail.com',
                password: hashedPassword,
                role: 'admin',
                isActive: true,
            });
            await adminUser.save();
            console.log('Tài khoản admin được tạo thành công');
        } else {
            console.log('Tài khoản admin đã tồn tại');
        }
    } catch (err) {
        console.error("Kết nối cơ sở dữ liệu thất bại:", err);
        process.exit(1);
    }
};

connectDatabase().then(() => {
    app.listen(port, function () {
        console.log("Server đang chạy tại cổng: " + port);
    });
}).catch((err) => console.log('Kết nối cơ sở dữ liệu thất bại:', err));