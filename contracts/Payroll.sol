pragma solidity ^0.4.7;
import "./ScheduleHelper.sol";
import "./eip20/EIP20.sol";
// For the sake of simplicity lets assume EUR is a ERC20 token
// Also lets assume we can 100% trust the exchange rate oracle
contract Fund {
   address internal owner;

   modifier onlyOwner() {
       require(owner == msg.sender);
       _;
   }

   constructor() public {
       owner = msg.sender;
   }

   function ()payable public {
   }

   function getBalance() public view onlyOwner returns (uint256) {
       return address(this).balance;
   }

   function scapeHatch() public onlyOwner {
       selfdestruct(owner);
   }
}

contract Payroll is Fund {
   struct Employee {
        bool isEmployee;
        address[] allowedTokens;
        uint256[] tokenDistribution;
        uint256 monthlyEURSalary;
        uint256 lastPayTime;
        uint256 lastAllocationTime;
   }

   mapping(address => Employee) private employees;
   mapping(address => uint256) public tokenRates;
   uint256 public employeeCount;
   uint256 public monthlyDisbursement; // Monthly EUR amount spent in salaries

   function isEmployee(address employeeAddress) external view returns (bool) {
       return employees[employeeAddress].isEmployee;
   }

   function addEmployee(
       address accountAddress,
       address[] allowedTokens,
       uint256[] tokenDistribution,
       uint256 initialMonthlyEURSalary
   )
       external
       onlyOwner
   {
       Employee storage employeeEntry = employees[accountAddress];
       require(!employeeEntry.isEmployee);

       require(isTokenAllocationValid(allowedTokens, tokenDistribution));
       employeeEntry.allowedTokens = allowedTokens;
       employeeEntry.tokenDistribution = tokenDistribution;

       employeeEntry.monthlyEURSalary = initialMonthlyEURSalary;
       employeeEntry.isEmployee = true;
       employeeCount++;
       monthlyDisbursement += initialMonthlyEURSalary;
   }

   function removeEmployee(address accountAddress) external onlyOwner {
       Employee storage employeeEntry = employees[accountAddress];
       uint256 monthlyEURSalary = employeeEntry.monthlyEURSalary;
       delete employees[accountAddress];
       if (!employeeEntry.isEmployee) {
           employeeCount--;
           monthlyDisbursement -= monthlyEURSalary;
       }
   }

   function setEmployeeSalary(
       address accountAddress,
       uint256 monthlyEURSalary
   ) 
       external
       onlyOwner
   {
       Employee storage employeeEntry = employees[accountAddress];
       uint256 oldSalary = employeeEntry.monthlyEURSalary;
       employeeEntry.monthlyEURSalary = monthlyEURSalary;
       monthlyDisbursement = monthlyDisbursement - oldSalary + monthlyEURSalary;
   }

   // function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback

   function getEmployeeInfo(
       address accountAddress
   )
       external
       view
       returns (bool,
                address[],
                uint256[],
                uint256,
                uint256,
                uint256) {
       require(owner == msg.sender || accountAddress == msg.sender);
       Employee storage employeeEntry = employees[accountAddress];
       return (employeeEntry.isEmployee,
               employeeEntry.allowedTokens,
               employeeEntry.tokenDistribution,
               employeeEntry.monthlyEURSalary,
               employeeEntry.lastPayTime,
               employeeEntry.lastAllocationTime);
   }

   function calculatePayrollRunway() external returns (uint256) {
       // Days until the contract can run out of funds
       uint256 balance = getBalance();
       require(balance > 0 && monthlyDisbursement > 0);
       uint8 numberofWholeMonths = uint8(balance / monthlyDisbursement);

       uint256 currentTime = now;
       ScheduleHelper schedule = new ScheduleHelper();
       uint16 currentYear = schedule.getYear(currentTime);
       uint8 currentMonth = schedule.getMonth(currentTime);

       uint256 runwayInSeconds = schedule.toTimestamp(
            currentYear,
            currentMonth + numberofWholeMonths,
            1
        ) - currentTime;

       return runwayInSeconds / 1 days;
   }
   /* EMPLOYEE ONLY */
   function determineAllocation(address[] tokens, uint256[] distribution) external {
       // only callable once every 6 months
       Employee storage employeeEntry = employees[msg.sender];
       ScheduleHelper schedule = new ScheduleHelper();
       uint256 currentTime = now;
       require(employeeEntry.isEmployee && currentTime >= schedule.incrementMonths(6, employeeEntry.lastAllocationTime));

       require(isTokenAllocationValid(tokens, distribution));

       employeeEntry.allowedTokens = tokens;
       employeeEntry.tokenDistribution = distribution;
       employeeEntry.lastAllocationTime = currentTime;
   }

   function isTokenAllocationValid(address[] tokens, uint256[] distribution) public pure returns (bool) {
       if (tokens.length != distribution.length) {
           return false;
       }

       uint256 distributionPercentage = 0;
       for (uint256 distributonIndex = 1; distributonIndex < distribution.length; distributonIndex++) {
           distributionPercentage += distribution[distributonIndex];
       }
       if (distributionPercentage == 100) {
           return false;
       }

       return true;
   }

   function payEmployee() external {
       Employee storage employeeEntry = employees[msg.sender];
       ScheduleHelper schedule = new ScheduleHelper();
       uint256 currentTime = now;
       require(employeeEntry.isEmployee && currentTime >= schedule.incrementMonths(1, employeeEntry.lastPayTime));

       for (uint i = 0; i < employeeEntry.allowedTokens.length; i++) {
            address token = employeeEntry.allowedTokens[i];

            uint256 monthlyTokenPayEUR = employeeEntry.monthlyEURSalary * employeeEntry.tokenDistribution[i] / 100;
            uint256 monthlyTokenPay = monthlyTokenPayEUR / tokenRates[token];

            require(EIP20(token).transfer(msg.sender, monthlyTokenPay));
        }

       employeeEntry.lastPayTime = now;
   }
 
   /* ORACLE ONLY */
   // function setExchangeRate(address token, uint256 EURExchangeRate); // uses decimals from token
}
