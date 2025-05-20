const multer = require('multer');
const path = require('path');

// Cấu hình lưu trữ file
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'assets/');
  },
  filename: function (req, file, cb) {
    const filePath = path.join('images/images-item', file.originalname); 
    cb(null, filePath); 
  }
});

const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'), false);
    }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter 
});

module.exports = upload;
