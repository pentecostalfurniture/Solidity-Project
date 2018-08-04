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
       require(!employees[accountAddress].isEmployee);
       employees[accountAddress].allowedTokens = allowedTokens;
       employees[accountAddress].monthlyEURSalary = initialMonthlyEURSalary;
       employees[accountAddress].isEmployee = true;
       employeeCount++;
       monthlyDisbursement += initialMonthlyEURSalary;
   }

   function removeEmployee(address accountAddress) external onlyOwner {
       uint256 monthlyEURSalary = employees[accountAddress].monthlyEURSalary;
       delete employees[accountAddress];
       if (!employees[accountAddress].isEmployee) {
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
       uint256 oldSalary = employees[accountAddress].monthlyEURSalary;
       employees[accountAddress].monthlyEURSalary = monthlyEURSalary;
       monthlyDisbursement = monthlyDisbursement - oldSalary + monthlyEURSalary;
   }

   function scapeHatch() external onlyOwner {
       selfdestruct(owner);
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
       return (employees[accountAddress].isEmployee,
               employees[accountAddress].allowedTokens,
               employees[accountAddress].monthlyEURSalary,
               employees[accountAddress].lastPayTime);
   }

   function payrollBurnrate() external view returns (uint256) {
       // Monthly EUR amount spent in salaries
        return monthlyDisbursement;
   }

   function calculatePayrollRunway() external view returns (uint256) {
       // Days until the contract can run out of funds
       require(getBalance() > 0);
       require(monthlyDisbursement > 0);
       uint256 numberofWholeMonths = getBalance() / monthlyDisbursement;
       return daysUntilNextMonth() + monthsToDays(numberofWholeMonths);
   }
   /* EMPLOYEE ONLY */
   function determineAllocation(address[] tokens, uint256[] distribution); // only callable once every 6 months
   function payEmployee() external {
        require(now >= employees[msg.sender].lastPayTime + 30 days);
        require(employees[msg.sender].isEmployee);
        employees[msg.sender].lastPayTime = now;
        msg.sender.transfer(employees[msg.sender].monthlyEURSalary);
   }
 
   /* ORACLE ONLY */
   function setExchangeRate(address token, uint256 EURExchangeRate); // uses decimals from token
}
