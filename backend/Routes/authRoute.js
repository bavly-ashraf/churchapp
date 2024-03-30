const express = require('express');
const router = express.Router();
const { signup, login } = require('../Controllers/authController');
const { signupValidation, loginValidation } = require('../Utils/authenticationSchema');
const { uploadImage } = require('../Utils/fileUpload');

router.post('/signup', uploadImage, signupValidation ,signup);

router.post('/login', loginValidation , login);

module.exports = router;