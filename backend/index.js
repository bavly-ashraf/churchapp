const express = require('express');
const app = express();
const cors = require('cors');
const port = 3000;
require('dotenv').config();

app.use(express.urlencoded({extended: true}));
app.use(express.json());
app.use(cors());


app.get('/', (req, res) => {
  res.send('Hello World!')
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
});