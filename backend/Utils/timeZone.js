 const moment = require('moment-timezone');
 
 const toLocalTimeZone = (date) => {
        return moment(date).tz('Africa/Cairo').format('hh:mm a').replace('pm','م').replace('am','ص');
    };

const toLocalDate = (date) => {
    return moment(date).tz('Africa/Cairo').format('DD/MM/yyyy');
}

module.exports = {toLocalTimeZone, toLocalDate};