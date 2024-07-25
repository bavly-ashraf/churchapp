const { getMessaging } = require("firebase-admin/messaging");

const getSameDays = (startTime,endTime) => {
    const startDate = new Date(startTime);
    const currentDate = new Date(startTime);
    const endDate = new Date(endTime);
    const sameDays = [];
    while(currentDate <= endDate){
        if(currentDate.getDay() == startDate.getDay()){
            sameDays.push(new Date(currentDate));
        }
        currentDate.setDate(currentDate.getDate() + 1);
    }
    return sameDays;
}

const sendPushNotification = async (title,body)=>{
    const topic = 'all';
    const message = {
        notification: {
            title,
            body
        },
        topic
    }
    try{
        await getMessaging().send(message)
    }catch(e){
        console.log(e);
    }
}

module.exports = {getSameDays, sendPushNotification};