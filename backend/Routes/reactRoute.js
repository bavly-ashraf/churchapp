const express = require('express');
const { verifyUser } = require('../Utils/verifyToken');
const { addReact, removeReact } = require('../Controllers/reactController');
const router = express.Router();

router.post('/:id', verifyUser, addReact);

router.delete('/:id', verifyUser, removeReact);


module.exports = router;