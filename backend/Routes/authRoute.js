const express = require('express');
const router = express.Router();
const { signup, login, firebaseToken } = require('../Controllers/authController');
const { signupValidation, loginValidation } = require('../Utils/authenticationSchema');
const { uploadImage } = require('../Utils/fileUpload');
const { verifyUser } = require('../Utils/verifyToken');

router.post('/signup', uploadImage, signupValidation ,signup);

router.post('/login', loginValidation , login);

router.post('/fb-token', verifyUser , firebaseToken);

module.exports = router;