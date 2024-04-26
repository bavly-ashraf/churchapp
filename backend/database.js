const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.CONNECTION_STRING).then(()=> console.log('database connected successfully...')).catch(err => console.log(err));