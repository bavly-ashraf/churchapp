const Reservation = require('../Models/Reservations');
const Post = require('../Models/Posts');
const AppError = require('../Utils/AppError');

const createReservation = async (req, res, next) => {
    const { id } = req.params;
    const { startTime, endTime , isFixed } = req.body;
    if(isFixed){
        let startDate = new Date(startTime);
        let currentDate = new Date(startTime);
        let endDate = new Date(endTime);
        while(currentDate <= endDate){
            if(currentDate.getDay() == startDate.getDay()){
                console.log('saturday');
            }
            currentDate.setDate(currentDate.getDate() + 1);
        }

    } else {        
        const foundedReservations = await Reservation.find({hall:id,status:'Approved',$or:[{startTime: {$lt: startTime},endTime: {$gt: startTime}}, {startTime: {$lt: endTime},endTime: {$gt: endTime}}, {startTime: {$lte: startTime},endTime: {$gte: endTime}}]});
        if (foundedReservations && foundedReservations.length > 0) return next(new AppError('Already reserved',404));
        const newReservation = await Reservation.create({...req.body, hall:id, reserver:req.user.id});
        res.status(201).json({message:'success',newReservation});
    }
};

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

const deleteReservation = async (req, res, next) => {
    const { id } = req.params;
    const deletedReservation = await Reservation.findByIdAndDelete(id).populate('hall');
    await Post.create({body:`${deletedReservation.hall.name} بقيت متاحة يوم ${deletedReservation.startTime.toLocaleDateString('en-GB')} في الوقت من ${deletedReservation.startTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')} ل ${deletedReservation.endTime.toLocaleString([], {hour: '2-digit',minute: '2-digit'}).replace('PM','م').replace('AM','ص')}`,creator:process.env.ADMIN_ID})
    res.status(200).json({message:'success', deletedReservation});
};

module.exports = {createReservation, changeStatus, deleteReservation, getPendingReservations, getReservationsForUser, getReservationsForCalendar};