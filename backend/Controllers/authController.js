const User = require("../Models/Users");
const bcrypt = require("bcrypt");
const AppError = require('../Utils/AppError');
const jwt = require('jsonwebtoken');
const cloudinary = require('../Utils/cloudinary');
const ChurchCode = require("../Models/ChurchCodes");
require('dotenv').config();



const signup = async (req,res,next)=>{
    // const {usename, email, password, mobile, profilepic, bio} = req.body;
    const { code } = req.body;
    const Church = await ChurchCode.findOne({code});
    if(!Church) return next(new AppError('Unauthorized',403));
    let imgUrl;
    if(req.file){
        const { secure_url } = await cloudinary.v2.uploader.upload(req.file.path , {folder: 'profilePics'});
        imgUrl = secure_url;
    }
    const createdUser = await User.create({...req.body, profilepic: imgUrl});
    createdUser.password = undefined;
    res.status(201).json({message: 'success', createdUser});
};

const login = async (req,res,next)=>{
    const {username, password} = req.body;
    const user = await User.findOne({username}).select('+password');
    if (!user) return next(new AppError('Wrong credentials', 404));
    const samePassword = await bcrypt.compare(password,user.password);
    if(!samePassword) return next(new AppError('Wrong credentials', 404));
    const token = await jwt.sign({id: user._id},process.env.SECRET_KEY);
    user.password = undefined;
    res.status(200).json({message:"success", user, token});
}


module.exports = {signup, login};