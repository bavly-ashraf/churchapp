const Hall = require('../Models/Halls');
const Reservation = require('../Models/Reservations');
const AppError = require('../Utils/AppError');

const createHall = async (req,res,next) => {
    const { name, floor , building } = req.body;
    const createdHall = await Hall.create({name,floor,building,creator: req.user.id });
    res.status(201).json({message:'success',createdHall})
    };

const getAllHalls = async (req,res,next)=> {
    const halls = await Hall.find();
    res.status(200).json({message: 'success', halls})
}

const deleteHallById = async (req,res,next)=> {
    const {id} = req.params;
    const deletedHall = await Hall.findByIdAndDelete(id);
    await Reservation.deleteMany({hall:id});
    res.status(200).json({message: 'success', deletedHall})
}


module.exports = { createHall, getAllHalls, deleteHallById };