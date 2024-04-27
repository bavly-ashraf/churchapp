const React = require('../Models/Reacts');
const AppError = require('../Utils/AppError');

const addOrRemoveReact = async (req, res, next) => {
    const { id } = req.params;
    const { react } = req.body;
    const userID = req.user.id;
    const foundedReact = await React.findOne({ post: id, creator: userID });
    if (foundedReact && foundedReact.react == react) {
        await React.findByIdAndDelete(foundedReact.id);
        res.status(200).json({ message: 'success' })

    }else if (foundedReact && foundedReact.react != react) {
        await React.findByIdAndDelete(foundedReact.id);
        const createdReact = await React.create({ react, post: id, creator: userID });
        res.status(201).json({ message: 'success', createdReact })
    }else{
        const createdReact = await React.create({ react, post: id, creator: userID });
        res.status(201).json({ message: 'success', createdReact })
    }
};

const getAllReactsForPost = async (req,res,next)=> {
    const { id } = req.params;
    const userID = req.user.id;
    const reacts = await React.find({post:id}).populate('creator');
    let isReacted = null;
    if(reacts && reacts.length > 0){
        isReacted = reacts.find(el => el.creator.id == userID)?.react;
    }
    res.status(200).json({message: 'success', reacts, isReacted})
}


module.exports = { addOrRemoveReact, getAllReactsForPost };