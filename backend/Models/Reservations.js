const { Schema, default: mongoose } = require('mongoose');

const ReservationSchema = new Schema({
    hall: {
        type: Schema.Types.ObjectId,
        ref: 'Hall',
        required: true,
    },
    unavailableAt: {
        type: Date,
        required: true,
    }
});

const Reservation = mongoose.model('Reservation', ReservationSchema);

module.exports = Reservation;