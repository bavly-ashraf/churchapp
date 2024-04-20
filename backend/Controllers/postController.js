const Post = require('../Models/Posts');
const AppError = require('../Utils/AppError');
const cloudinary = require('../Utils/cloudinary');

const createPost = async (req,res,next) => {
if(req.files) {
    req.body.attachments = [];
    for(let file of req.files){
        const { secure_url } = await cloudinary.v2.uploader.upload(file.path, {folder:'attachments'});
        req.body.attachments.push(secure_url);
    }
}
const createdPost = await Post.create({...req.body,creator: req.user.id });
res.status(201).json({message:'success',createdPost})
};


const editPost = async (req,res,next) => {
    const {id} = req.params;
    const {body} = req.body;
    const post = await Post.findById(id);
    if(req.user.id != post.creator.toString()) return next(new AppError('Only post creator can edit it', 403));
    const editedPost = await Post.findByIdAndUpdate(id,{body},{new:true});
    res.status(200).json({message:'success',editedPost});
};


const getAllPosts = async (req,res,next) => {
    const {skip,limit} = req.query;
    const allPosts = await Post.find().skip(skip).limit(limit);
    res.status(200).json({message:'success',allPosts,count:allPosts.length});
};

const getPostByID = async (req,res,next) => {
    const {id} = req.params;
    const post = await Post.findById(id);
    res.status(200).json({message:'success',post});
}

const deletePost = async (req,res,next) => {
    const {id} = req.params;
    const post = await Post.findById(id);
    if(req.user.id != post.creator.toString()) return next(new AppError('Only post creator can delete it', 403));
    const deletedPost = await Post.findByIdAndDelete(id);
    res.status(200).json({message:'success',deletedPost});
}

module.exports = {createPost, getAllPosts, editPost, getPostByID, deletePost};