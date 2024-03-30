const {Schema, default: mongoose} = require('mongoose');

const reactSchema = new Schema({
    react: {
        type: String,
        enum: ['Like','Dislike','Love','Sad'],
        required: true,
    },
    post: {
        type: Schema.Types.ObjectId,
        ref: 'Post',
        required: true,
    },
    creator: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    }
});

const React = mongoose.model('React',reactSchema);

module.exports = React;