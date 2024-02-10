const {Schema, default: mongoose} = require('mongoose');

const userSchema = new Schema({
    username: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
        select: false,
    },
    mobile: {
        type: String,
        required: true,
        unique: true,
    },
    profilepic: {
        type: String,
        default: '',
    },
    bio: {
        type: String,
        default: '',
    },
    role: {
        type: String,
        enum: ['admin','user'],
        default: 'user',
    },
    createdAt: {
        type: Date,
        default: Date.now,
    }
});

const User = mongoose.model('User',userSchema);

module.exports = User;