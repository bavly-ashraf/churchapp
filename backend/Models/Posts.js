const {Schema, default: mongoose} = require('mongoose');

const postSchema = new Schema({
    body: {
        type: String,
        required: true,
    },
    attachments: [{
        type: String,
    }],
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

const Post = mongoose.model('Post',postSchema);

module.exports = Post;