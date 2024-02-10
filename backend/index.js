const express = require('express');
const app = express();
require('dotenv').config();
const cors = require('cors');
const morgan = require('morgan');
const port = 3000;

app.use(express.urlencoded({extended: true}));
app.use(express.json());
app.use(cors());
app.use(morgan('dev'));


app.get('/', (req, res) => {
  res.send('Hello World!')
});


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
  console.log(`Example app listening on port ${port}`)
});