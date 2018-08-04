pragma solidity ^0.4.7;

contract Scheduler {
    // Ideally obtained from an oracle due to leap seconds - set as 86400 for demonstration purposes
    uint256 secondsInAday = 86400;
    
    function nextMonth() public view returns (uint256) {
        // Returns time at which the next month starts
        return timeUntilNextMonth() - now;
    }
    
    function timeUntilNextMonth() public view returns (uint256) {
        // Must get from an oracle - return an arbitrary number for demonstration purposes
        return 15 * secondsInAday;
    }
    
    function daysUntilNextMonth() public view returns (uint256) {
        return secondsToDays(timeUntilNextMonth());
    }

    function monthsToDays(uint256 months) public pure returns (uint256) {
        // Must get from an oracle
        return months * 30;
    }
    
    function secondsToDays(uint256 seconds_) public view returns (uint256) {
        return seconds_ / secondsInAday;
    }
}
