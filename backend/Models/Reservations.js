const { required } = require('joi');
const { Schema, default: mongoose } = require('mongoose');

const ReservationSchema = new Schema({
    hall: {
        type: Schema.Types.ObjectId,
        ref: 'Hall',
        required: true,
    },
    startTime: {
        type: Date,
        required: true,
    },
    endTime: {
        type: Date,
        required: true,
    },
    status: {
        type: String,
        enum: ['Pending','Approved','Rejected'],
        default: 'Pending',
    },
    reason: {
        type: String,
        required: true,
    },
    reserver: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
});

const Reservation = mongoose.model('Reservation', ReservationSchema);

module.exports = Reservation;