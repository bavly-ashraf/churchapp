const express = require('express');
const { verifyAdmin, verifyUser } = require('../Utils/verifyToken');
const { createReservation, changeStatus, confirmReservation, deleteReservation, getPendingReservationsCount, getAllPendingReservations, getPendingReservations, getReservationsForUser, getReservationsForCalendar, scheduledNotification} = require('../Controllers/reservationController');
const router = express.Router();

router.post('/:id', verifyUser, createReservation);

router.post('/status/:id', verifyAdmin, changeStatus);

router.post('/confirmation/:id', verifyUser, confirmReservation);

router.get('/pending', verifyAdmin, getAllPendingReservations);

router.get('/pending/count', verifyAdmin, getPendingReservationsCount);

router.get('/pending/:hallID', verifyAdmin, getPendingReservations);

router.get('/user/:hallID', verifyUser, getReservationsForUser);

router.get('/calendar/:hallID', verifyUser, getReservationsForCalendar);

router.delete('/:id', verifyUser, deleteReservation);

router.get('/scheduled', verifyUser, scheduledNotification);


module.exports = router;