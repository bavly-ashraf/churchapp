// const multer = require('multer');

const fileFilter = (req, file, cb) => {

    if (!file.mimetype.startsWith('image')) {
        cb(null, false)
    } else {
        cb(null, true)
    }
  
  };

//   const storage = multer.diskStorage({
//     destination: function (req, file, cb) {
//       cb(null, 'uploads/')
//     },
//     filename: function (req, file, cb) {
//       const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
//       cb(null, file.fieldname + '-' + uniqueSuffix)
//     }
//   })

  // const upload = multer({ dest: 'uploads/', fileFilter});
  
  // const uploadImage = upload.single('profilepic');

  // const uploadAttachments = upload.array('attachments', 4);
  

  // module.exports = {uploadImage, uploadAttachments};