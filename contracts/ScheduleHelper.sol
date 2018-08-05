pragma solidity ^0.4.7;
import "./DateTime.sol";

contract ScheduleHelper is DateTime {
    function incrementMonths(uint8 _months, uint _timestamp) external returns (uint) {
        DateTime dateTime = new DateTime();
        uint16 year = dateTime.getYear(_timestamp);
        uint8 month = dateTime.getMonth(_timestamp);

        uint8 newMonth = month + _months;
        while(newMonth > 12){
            newMonth -= 12;
            year++;
        }

        // get new timestamp
        return dateTime.toTimestamp(
            year,
            newMonth,
            dateTime.getDay(_timestamp),
            dateTime.getHour(_timestamp),
            dateTime.getMinute(_timestamp),
            dateTime.getSecond(_timestamp)
        );
    }
}
