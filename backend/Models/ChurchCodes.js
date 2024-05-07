const { Schema, default: mongoose } = require('mongoose');

const ChurchCodeSchema = new Schema({
    name: {
        type: String,
        required: true,
        unique: true,
    },
    code: {
        type: String,
        required: true,
        unique: true,
    },
});

const ChurchCode = mongoose.model('ChurchCode', ChurchCodeSchema);

module.exports = ChurchCode;