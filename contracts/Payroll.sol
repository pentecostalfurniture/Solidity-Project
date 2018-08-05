pragma solidity ^0.4.7;
import "./Scheduler.sol";
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

contract Payroll is Fund, Scheduler {
   struct Employee {
        bool isEmployee;
        address[] allowedTokens;
        uint256 monthlyEURSalary;
        uint256 lastPayTime;
   }

   mapping(address => Employee) private employees;
   uint256 employeeCount;
   uint256 monthlyDisbursement;

   function isEmployee(address employeeAddress) external view returns (bool) {
       return employees[employeeAddress].isEmployee;
   }

   function getEmployeeCount() external view returns (uint256) {
       return employeeCount;
   }

   function addEmployee(
       address accountAddress,
       address[] allowedTokens,
       uint256 initialMonthlyEURSalary
   )
       external
       onlyOwner
   {
       Employee storage employeeEntry = employees[accountAddress];
       require(!employeeEntry.isEmployee);
       employeeEntry.allowedTokens = allowedTokens;
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
                uint256,
                uint256) {
       require(owner == msg.sender || accountAddress == msg.sender);
       Employee storage employeeEntry = employees[accountAddress];
       return (employeeEntry.isEmployee,
               employeeEntry.allowedTokens,
               employeeEntry.monthlyEURSalary,
               employeeEntry.lastPayTime);
   }

   function payrollBurnrate() external view returns (uint256) {
       // Monthly EUR amount spent in salaries
        return monthlyDisbursement;
   }

   function calculatePayrollRunway() external view returns (uint256) {
       // Days until the contract can run out of funds
       require(getBalance() > 0 && monthlyDisbursement > 0);
       uint256 numberofWholeMonths = getBalance() / monthlyDisbursement;
       return daysUntilNextMonth() + monthsToDays(numberofWholeMonths);
   }
   /* EMPLOYEE ONLY */
   function determineAllocation(address[] tokens, uint256[] distribution); // only callable once every 6 months
   function payEmployee() external {
        Employee storage employeeEntry = employees[msg.sender];
        require(employeeEntry.isEmployee && now >= employeeEntry.lastPayTime + 30 days);
        employeeEntry.lastPayTime = now;
        msg.sender.transfer(employeeEntry.monthlyEURSalary);
   }
 
   /* ORACLE ONLY */
   function setExchangeRate(address token, uint256 EURExchangeRate); // uses decimals from token
}
