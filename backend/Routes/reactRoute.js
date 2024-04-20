const express = require('express');
const { verifyUser } = require('../Utils/verifyToken');
const { addOrRemoveReact } = require('../Controllers/reactController');
const router = express.Router();

router.post('/:id', verifyUser, addOrRemoveReact);


module.exports = router;