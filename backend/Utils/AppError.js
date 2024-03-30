class AppError extends Error{
    constructor(message, statusCode, errors ){
        super(message);
        this.statusCode = statusCode;
        this.status = `${statusCode}`.startsWith('4')? 'fail' : 'error';
        this.errors = errors;
    }
}

module.exports = AppError;