const Joi = require('joi');
const AppError = require('./AppError');


const signupSchema = Joi.object({
    username: Joi.string().alphanum().min(3).max(30).required(),
    email: Joi.string().email({ minDomainSegments: 2, tlds: { allow: ['com', 'net','org'] } }),
    password: Joi.string().pattern(new RegExp('^[a-zA-Z0-9]{3,30}$')).required(),
    mobile: Joi.string().pattern(/^(\+201|01|00201)[0-2,5]{1}[0-9]{8}/).required(),
    bio: Joi.string(),
    role: Joi.string(),
});


const loginSchema = Joi.object({
    username: Joi.string().alphanum().min(3).max(30).required(),
    password: Joi.string().pattern(new RegExp('^[a-zA-Z0-9]{3,30}$')).required(),
});




const signupValidation = async (req,res,next) => {
    try {
        const value = await signupSchema.validateAsync(req.body, {abortEarly:false});
        if (value) next();
    }
    catch (err) { 
        next(new AppError(err.message,400,err.details))
    }
};

const loginValidation = async (req,res,next) => {
    try {
        const value = await loginSchema.validateAsync(req.body, {abortEarly:false});
        if (value) next();
    }
    catch (err) { 
        next(new AppError(err.message,400,err.details))
    }
}


module.exports = {signupValidation,loginValidation};