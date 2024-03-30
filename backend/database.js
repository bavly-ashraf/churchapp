const mongoose = require('mongoose');
mongoose.connect('mongodb://127.0.0.1:27017/churchApp').then(()=> console.log('database connected successfully...')).catch(err => console.log(err));