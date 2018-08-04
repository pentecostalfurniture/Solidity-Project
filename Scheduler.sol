pragma solidity ^0.4.7;

contract Scheduler {
    function nextMonth() internal view returns (uint256) {
        // Returns time at which the next month starts
        return timeUntilNextMonth() - now;
    }
    
    function timeUntilNextMonth() internal pure returns (uint256) {
        // Must get from an oracle - return an arbitrary number for demonstration purposes
        return 15 days;
    }
    
    function daysUntilNextMonth() internal pure returns (uint256) {
        return secondsToDays(timeUntilNextMonth());
    }

    function monthsToDays(uint256 months) internal pure returns (uint256) {
        // Must get from an oracle
        return months * 30;
    }
    
    function secondsToDays(uint256 seconds_) internal pure returns (uint256) {
        return seconds_ / 1 days;
    }
}
