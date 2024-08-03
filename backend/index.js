const express = require('express');
const app = express();
require('express-async-errors');
require('dotenv').config();
const cors = require('cors');
// const cron = require('node-cron');
const morgan = require('morgan');
const port = process.env.PORT;

require('./database');
const authRoute = require('./Routes/authRoute');
const postRoute = require('./Routes/postRoute');
const reactRoute = require('./Routes/reactRoute');
const hallRoute = require('./Routes/hallRoute');
const reservationRoute = require('./Routes/reservationRoute');

//////////////////// Firebase Initialization ////////////////////////
const admin = require("firebase-admin");
const functions  = require('firebase-functions');
const serviceAccount = require("./Utils/church-reservation-serviceKey.json");
const Reservation = require('./Models/Reservations');
const { sendPushNotification } = require('./Utils/helpers');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
/////////////////////////////////////////////////////////////////////

/////////////////// Repeatable Job to get users that have reservations today //////////////////
functions.pubsub.schedule(`0 0 * * *`).timeZone('Africa/Cairo').onRun(async ()=> {
  const todaysDate = new Date();
  todaysDate.setHours(0,0,0,0);
  const tomorrowsDate = new Date(todaysDate);
  tomorrowsDate.setDate(todaysDate.getDate() + 1);
  const todaysReservations = await Reservation.find({startTime:{$gte:todaysDate,$lt:tomorrowsDate},isConfirmed:false},'reserver hall startTime endTime').populate('reserver hall','firebaseToken name -_id');
  todaysReservations.forEach(reservation => {
    sendPushNotification('تأكيد الحجز', `من فضلك دوس هنا عشان تأكد حجزك ل${reservation.hall.name} بكرة في الوقت من ${reservation.startTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')} ل ${reservation.endTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')}`,reservation.reserver.firebaseToken,reservation.id);
  });
  // if(usersToken?.length > 0){
  //   sendPushNotification('تأكيد الحجز', 'من فضلك أكد حجزك',usersToken);
  // }
});
// cron.schedule('0 0 0 * * *', async ()=> {
//   const todaysDate = new Date();
//   todaysDate.setHours(0,0,0,0);
//   const tomorrowsDate = new Date(todaysDate);
//   tomorrowsDate.setDate(todaysDate.getDate() + 1);
//   const todaysReservations = await Reservation.find({startTime:{$gte:todaysDate,$lt:tomorrowsDate},isConfirmed:false},'reserver hall startTime endTime').populate('reserver hall','firebaseToken name -_id');
//   todaysReservations.forEach(reservation => {
//     sendPushNotification('تأكيد الحجز', `من فضلك دوس هنا عشان تأكد حجزك ل${reservation.hall.name} بكرة في الوقت من ${reservation.startTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')} ل ${reservation.endTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')}`,reservation.reserver.firebaseToken,reservation.id);
//   });
//   // if(usersToken?.length > 0){
//   //   sendPushNotification('تأكيد الحجز', 'من فضلك أكد حجزك',usersToken);
//   // }
// },{runOnInit:true});
//////////////////////////////////////////////////////////////////////////////////////////////


app.use(express.urlencoded({extended: true}));
app.use(express.json());
app.use(cors());
app.use(morgan('dev'));

// routes
app.use('/user', authRoute);
app.use('/post', postRoute);
app.use('/react', reactRoute);
app.use('/hall', hallRoute);
app.use('/reservation', reservationRoute);


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