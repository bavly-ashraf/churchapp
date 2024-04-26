const express = require('express');
const { verifyUser } = require('../Utils/verifyToken');
const { addOrRemoveReact, getAllReactsForPost } = require('../Controllers/reactController');
const router = express.Router();

router.post('/:id', verifyUser, addOrRemoveReact);

router.get('/:id', verifyUser, getAllReactsForPost);


module.exports = router;