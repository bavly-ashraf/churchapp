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
},{
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

postSchema.virtual('postReacts',{
    ref: 'React',
    localField: '_id',
    foreignField: 'post'
});

const Post = mongoose.model('Post',postSchema);

module.exports = Post;