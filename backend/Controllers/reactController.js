const React = require('../Models/Reacts');
const AppError = require('../Utils/AppError');

const addOrRemoveReact = async (req,res,next) => {
const {id} = req.params;
const {react} = req.body;
const userID = req.user.id;
const foundedReact = await React.findOne({post:id,creator:userID});
let createdReact;
if(foundedReact){
    await React.findByIdAndDelete(foundedReact.id);
}
if(react && foundedReact?.react != react){
    createdReact = await React.create({react,post:id,creator:userID});
}
res.status(201).json({message:'success',createdReact})
};


module.exports = {addOrRemoveReact};