const express = require('express');
const { verifyAdmin, verifyUser } = require('../Utils/verifyToken');
const { createReservation, changeStatus, confirmReservation, deleteReservation, getPendingReservations, getReservationsForUser, getReservationsForCalendar} = require('../Controllers/reservationController');
const router = express.Router();

router.post('/:id', verifyUser, createReservation);

router.post('/status/:id', verifyAdmin, changeStatus);

router.post('/confirmation/:hallID', verifyUser, confirmReservation);

router.get('/pending/:hallID', verifyAdmin, getPendingReservations);

router.get('/user/:hallID', verifyUser, getReservationsForUser);

router.get('/calendar/:hallID', verifyUser, getReservationsForCalendar);

router.delete('/:id', verifyUser, deleteReservation);


module.exports = router;