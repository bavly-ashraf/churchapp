const jwt = require('jsonwebtoken');
const AppError = require('./AppError');
const User = require('../Models/Users');
require('dotenv').config();

const verifyUser = async (req,res,next) => {
    const token = req.headers.authorization;
    if(!token) return next(new AppError('Unauthenticated',401));
    const {id} = await jwt.verify(token, process.env.SECRET_KEY);
    const user = await User.findById(id);
    if(!user) return next(new AppError('User not found',404));
    req.user = user;
    next();
};

const verifyAdmin = async (req,res,next) => {
    const token = req.headers.authorization;
    if(!token) return next(new AppError('Unauthenticated',401));
    const {id} = await jwt.verify(token, process.env.SECRET_KEY);
    const user = await User.findById(id);
    if(!user) return next(new AppError('User not found',404));
    if(user.role != 'admin') return next(new AppError('Unauthorized',403));
    req.user = user;
    next();
};

module.exports = {verifyUser,verifyAdmin};