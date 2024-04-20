const React = require('../Models/Reacts');
const AppError = require('../Utils/AppError');

const addOrRemoveReact = async (req, res, next) => {
    const { id } = req.params;
    const { react } = req.body;
    const userID = req.user.id;
    const foundedReact = await React.findOne({ post: id, creator: userID });
    if (foundedReact) {
        await React.findByIdAndDelete(foundedReact.id);
        res.status(200).json({ message: 'success' })

    }
    if (react && foundedReact?.react != react) {
        const createdReact = await React.create({ react, post: id, creator: userID });
        res.status(201).json({ message: 'success', createdReact })

    }
};


module.exports = { addOrRemoveReact };