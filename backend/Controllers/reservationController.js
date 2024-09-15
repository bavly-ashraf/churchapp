const Reservation = require('../Models/Reservations');
const Post = require('../Models/Posts');
const AppError = require('../Utils/AppError');
const {getSameDays, sendPushNotification} = require('../Utils/helpers');

const createReservation = async (req, res, next) => {
    const { id } = req.params;
    const { startTime, endTime , isFixed } = req.body;
    if(isFixed){
        const sameDays = getSameDays(startTime,endTime);
        const endDate = new Date(endTime);
        for(let day of sameDays){
            let endFixedTime = new Date(day.getFullYear(),day.getMonth(),day.getDate(),endDate.getHours(),endDate.getMinutes(),endDate.getSeconds()).toISOString();
            day = day.toISOString();
            const foundedReservations = await Reservation.find({hall:id,status:'Approved',$or:[{startTime: {$lt: day},endTime: {$gt: day}}, {startTime: {$lt: endFixedTime},endTime: {$gt: endFixedTime}}, {startTime: {$lte: day},endTime: {$gte: endFixedTime}}]});
            if (foundedReservations && foundedReservations.length > 0) return next(new AppError('Already reserved',404));
        }
        sameDays.forEach(async el => {
            let endFixedTime = new Date(el.getFullYear(),el.getMonth(),el.getDate(),endDate.getHours(),endDate.getMinutes(),endDate.getSeconds()).toISOString();
            el = el.toISOString();
            await Reservation.create({...req.body, startTime: el, endTime: endFixedTime, status: req.user.role == 'admin'? 'Approved': 'Pending', hall:id, reserver:req.user.id});
        });
        res.status(201).json({message:'success'});
    } else {        
        const foundedReservations = await Reservation.find({hall:id,status:'Approved',$or:[{startTime: {$lt: startTime},endTime: {$gt: startTime}}, {startTime: {$lt: endTime},endTime: {$gt: endTime}}, {startTime: {$lte: startTime},endTime: {$gte: endTime}}]});
        if (foundedReservations && foundedReservations.length > 0) return next(new AppError('Already reserved',404));
        const newReservation = await Reservation.create({...req.body, hall:id, status: req.user.role == 'admin'? 'Approved': 'Pending', reserver:req.user.id});
        res.status(201).json({message:'success',newReservation});
    }
};

const getPendingReservationsCount = async (req, res, next) => {
    const foundedReservationsCount = await Reservation.countDocuments({status:'Pending'});
    res.status(200).json({message:'success', foundedReservationsCount});
}

const getAllPendingReservations = async (req, res, next) => {
    const foundedReservations = await Reservation.find({status:'Pending'}).populate('reserver hall').sort({'createdAt': -1});
    res.status(200).json({message:'success', foundedReservations});
}

const getPendingReservations = async (req, res, next) => {
    const { hallID } = req.params;
    const foundedReservations = await Reservation.find({hall:hallID, status:'Pending'}).populate('reserver').sort({'createdAt': -1});
    res.status(200).json({message:'success', foundedReservations});
};

const getReservationsForUser = async (req, res, next) => {
    const { hallID } = req.params;
    const foundedReservations = await Reservation.find({hall:hallID,reserver:req.user.id}).populate('reserver').sort({'createdAt': -1});
    res.status(200).json({message:'success', foundedReservations});
};

const getReservationsForCalendar = async (req, res, next) => {
    const { hallID } = req.params;
    const { firstDay, lastDay } = req.query;
    const foundedReservations = await Reservation.find({hall:hallID, startTime:{$gte:firstDay, $lte:lastDay} , status:'Approved'}).populate('reserver').sort({'startTime': -1});
    res.status(200).json({message:'success',foundedReservations});
};

const changeStatus = async (req, res, next) => {
    const { id } = req.params;
    const { status } = req.body;
    if(status == 'Approved'){
        const foundedReservation = await Reservation.findById(id);
        const conflictingReservations = await Reservation.find({hall:foundedReservation.hall,status:'Approved',$or:[{startTime: {$lt: foundedReservation.startTime},endTime: {$gt: foundedReservation.startTime}}, {startTime: {$lt: foundedReservation.endTime},endTime: {$gt: foundedReservation.endTime}}, {startTime: {$lte: foundedReservation.startTime},endTime: {$gte: foundedReservation.endTime}}]});
        if (conflictingReservations && conflictingReservations.length > 0) return next(new AppError('Already reserved',404));
    }
    const updatedReservation = await Reservation.findByIdAndUpdate(id, {status},{new:true});
    res.status(200).json({message:'success',updatedReservation});
};

const confirmReservation = async (req, res, next) => {
    const { id } = req.params;
    const { confirmAction } = req.body;
    if(confirmAction){
        const updatedReservation = await Reservation.findByIdAndUpdate(id, { isConfirmed: true }, {new: true});
        res.status(200).json({message:'success', updatedReservation});
    }else {
        deleteReservation(req,res,next);
    }
};

const deleteReservation = async (req, res, next) => {
    const { id } = req.params;
    const deletedReservation = await Reservation.findByIdAndDelete(id).populate('hall');
    const body = `${deletedReservation.hall.name} بقيت متاحة يوم ${deletedReservation.startTime.toLocaleDateString('en-GB')} في الوقت من ${deletedReservation.startTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')} ل ${deletedReservation.endTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')}`;
    await Post.create({body,creator:process.env.ADMIN_ID})
    await sendPushNotification('قاعة متاحة',body);
    res.status(200).json({message:'success', deletedReservation});
};


const scheduledNotification = async (req, res, next) => {
    const todaysDate = new Date();
    todaysDate.setHours(0,0,0,0);
    const tomorrowsDate = new Date(todaysDate);
    tomorrowsDate.setDate(todaysDate.getDate() + 1);
    const todaysReservations = await Reservation.find({startTime:{$gte:todaysDate,$lt:tomorrowsDate},status:'Approved',isConfirmed:false},'reserver hall startTime endTime').populate('reserver hall','firebaseToken name -_id');
    todaysReservations.forEach(reservation => {
      sendPushNotification('تأكيد الحجز', `من فضلك دوس هنا عشان تأكد حجزك ل${reservation.hall.name} بكرة في الوقت من ${reservation.startTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')} ل ${reservation.endTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')}`,reservation.reserver.firebaseToken,reservation.id);
    });
    res.status(200).json({message:'success'});
};

module.exports = {createReservation, changeStatus, confirmReservation, deleteReservation, getPendingReservationsCount, getAllPendingReservations, getPendingReservations, getReservationsForUser, getReservationsForCalendar, scheduledNotification};