exports.getAdmin = (req, res) => {
  res.render("../views/admin.page.ejs");
};

//Movie
exports.getManageMovies = (req, res) => {
  res.render("../views/movie-admin.ejs");
};

exports.getManageCreateMovie = (req, res) => {
  res.render("../views/movie-create.ejs");
};

exports.getManageUpdateMovie = (req, res) => {
  res.render("../views/movie-edit.ejs");
};

//Genre
exports.getManageGenres = (req, res) => {
  res.render("../views/genre-admin.ejs");
};

exports.getManageCreateGenre = (req, res) => {
  res.render("../views/genre-create.ejs");
};

exports.getManageUpdateGenre = (req, res) => {
  res.render("../views/genre-edit.ejs");
};

//User
exports.getManageUser = (req, res) => {
  res.render("../views/user-admin.ejs");
};

exports.getManageUpdateUser = (req, res) => {
  res.render("../views/user-edit.ejs");
};


//Comment
exports.getManageCommentMovie = (req, res) => {
  res.render("../views/comment-show-admin.ejs");
};


