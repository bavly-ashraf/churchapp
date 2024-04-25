const express = require('express');
const { verifyAdmin, verifyUser } = require('../Utils/verifyToken');
const { createPost, getAllPosts, getPostByID, deletePost, editPost } = require('../Controllers/postController');
const { uploadAttachments } = require('../Utils/fileUpload');
const router = express.Router();

// router.post('/', verifyAdmin, uploadAttachments, createPost);
router.post('/', verifyAdmin, createPost);

router.put('/:id', verifyAdmin, editPost);

router.get('/', verifyUser, getAllPosts);

router.get('/:id', verifyUser, getPostByID);

router.delete('/:id', verifyAdmin, deletePost);


module.exports = router;