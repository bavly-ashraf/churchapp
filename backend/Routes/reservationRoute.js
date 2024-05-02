const express = require('express');
const { verifyAdmin, verifyUser } = require('../Utils/verifyToken');
const { createReservation, changeStatus, deleteReservation, getPendingReservations, getReservationsForUser, getReservationsForCalendar} = require('../Controllers/reservationController');
const router = express.Router();

router.post('/:id', verifyUser, createReservation);

router.post('/status/:id', verifyAdmin, changeStatus);

router.get('/pending/:hallID', verifyAdmin, getPendingReservations);

router.get('/user/:hallID', verifyUser, getReservationsForUser);

router.get('/calendar/:hallID', verifyUser, getReservationsForCalendar);

router.delete('/:id', verifyAdmin, deleteReservation);


module.exports = router;