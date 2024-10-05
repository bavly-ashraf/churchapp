 const moment = require('moment');
 
 const toLocalTimeZone = (date) => {
        var today = moment(date);
        today.tz('Africa/Cairo').format();
    };

module.exports = {toLocalTimeZone};