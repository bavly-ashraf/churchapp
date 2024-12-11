 const moment = require('moment-timezone');
 
 const toLocalTimeZone = (date) => {
        return moment(date).tz('Africa/Cairo').toDate();
    };

module.exports = {toLocalTimeZone};