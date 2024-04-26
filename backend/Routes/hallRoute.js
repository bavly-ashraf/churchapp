const express = require('express');
const { verifyAdmin, verifyUser } = require('../Utils/verifyToken');
const { createHall, getAllHalls, deleteHallById } = require('../Controllers/hallController');
const router = express.Router();

router.post('/', verifyAdmin, createHall);

router.get('/', verifyUser, getAllHalls);

router.delete('/:id', verifyAdmin, deleteHallById);


module.exports = router;