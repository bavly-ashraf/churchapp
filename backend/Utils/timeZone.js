 const moment = require('moment-timezone');
 
 const toLocalTimeZone = (date) => {
        return new Date(moment(date).tz('Africa/Cairo').format());
    };

module.exports = {toLocalTimeZone};