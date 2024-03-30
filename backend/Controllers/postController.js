const Post = require('../Models/Posts');
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
    const post = await Post.findByIdAndUpdate(id,{body},{new:true});
    res.status(200).json({message:'success',post});
};


const getAllPosts = async (req,res,next) => {
    const allPosts = await Post.find();
    res.status(200).json({message:'success',allPosts});
};

const getPostByID = async (req,res,next) => {
    const {id} = req.params;
    const post = await Post.findById(id);
    res.status(200).json({message:'success',post});
}

const deletePost = async (req,res,next) => {
    const {id} = req.params;
    const post = await Post.findByIdAndDelete(id);
    res.status(200).json({message:'success',post});
}

module.exports = {createPost, getAllPosts, editPost, getPostByID, deletePost};