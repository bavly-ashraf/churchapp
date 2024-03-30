const { Schema, default: mongoose } = require('mongoose');

const HallSchema = new Schema({
    name: {
        type: String,
        required: true,
        unique: true,
    },
});

const Hall = mongoose.model('Hall', HallSchema);

module.exports = Hall;