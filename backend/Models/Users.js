const {Schema, default: mongoose} = require('mongoose');
const bcrypt = require('bcrypt');
const Post = require('./Posts');
const React = require('./Reacts');
const Reservation = require('./Reservations');

const userSchema = new Schema({
    username: {
        type: String,
        required: true,
        unique: true,
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
    firebaseToken: {
        type: String
    },
    createdAt: {
        type: Date,
        default: Date.now,
    }
});

userSchema.pre('save', async function() {
    const { password } = this;
    if (this.isModified('password')){
        const hashedPassword = await bcrypt.hash(password, 10);
        this.password = hashedPassword;
    }
});

userSchema.pre('deleteOne',async function(){
    const { id } = this;
    await Post.deleteMany({creator:id});
    await React.deleteMany({creator:id});
    await Reservation.deleteMany({reserver:id});
})

const User = mongoose.model('User',userSchema);

module.exports = User;