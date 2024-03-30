const React = require('../Models/Reacts');
const AppError = require('../Utils/AppError');

const addReact = async (req,res,next) => {
const {id} = req.params;
const {react} = req.body;
const userID = req.user.id;
const foundedReact = await React.findOne({post:id,creator:userID});
if(foundedReact){
    await React.findByIdAndDelete(foundedReact.id);
}
const createdReact = await React.create({react,post:id,creator:userID});
res.status(201).json({message:'success',createdReact})
};


const removeReact = async (req,res,next) => {
    const {id} = req.params;
    const userID = req.user.id;
    const react = await React.findOne({post:id,creator:userID});
    if (!react) return next(new AppError('couldn\'t find react on this post by this user',404));
    const deletedReact = await React.findByIdAndDelete(react.id);
    res.status(200).json({message:'success',deletedReact});
};


module.exports = {addReact, removeReact};