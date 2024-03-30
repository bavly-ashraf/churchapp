const express = require('express');
const app = express();
require('express-async-errors');
require('dotenv').config();
const cors = require('cors');
const morgan = require('morgan');
const port = process.env.PORT;

require('./database');
const authRoute = require('./Routes/authRoute');
const postRoute = require('./Routes/postRoute');
const reactRoute = require('./Routes/reactRoute');


app.use(express.urlencoded({extended: true}));
app.use(express.json());
app.use(cors());
app.use(morgan('dev'));

// routes
app.use('/user', authRoute);
app.use('/post', postRoute);
app.use('/react', reactRoute);


// global error handler
app.use((err,req,res,next)=>{
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    status: statusCode,
    message: err.message || 'internal server error',
    errors: err.errors || []
  })
})

// activating app on port
app.listen(port, () => {
  console.log(`App listening on port ${port}`)
});