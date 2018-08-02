pragma solidity ^0.4.7;
// For the sake of simplicity lets assume EUR is a ERC20 token
// Also lets assume we can 100% trust the exchange rate oracle
contract PayrollInterface {
   /* OWNER ONLY */
   address private owner;

   modifier onlyOwner() {
       require(owner == msg.sender);
       _;
   }

   constructor() public {
       owner = msg.sender;
   }

   struct Employee {
        address[] allowedTokens;
        uint256 yearlyEURSalary;
   }

   mapping(address => Employee) private employees;

   function addEmployee(
       address accountAddress,
       address[] allowedTokens,
       uint256 initialYearlyEURSalary
   )
       public
       onlyOwner
   {
       employees[accountAddress].allowedTokens = allowedTokens;
       employees[accountAddress].yearlyEURSalary = initialYearlyEURSalary;
   }

   function setEmployeeSalary(
       address accountAddress,
       uint256 yearlyEURSalary
   ) 
       public
       onlyOwner
   {
       employees[accountAddress].yearlyEURSalary = yearlyEURSalary;
   }

   function removeEmployee(address accountAddress) public onlyOwner {
       delete employees[accountAddress];
   }

   uint256 private funds;

   function addFunds() payable public {
       // Prevent possible overflow
       require((funds + msg.value) >= funds);
       funds += msg.value;
   }

   function scapeHatch();
   // function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback
 
   function getEmployeeCount() constant returns (uint256);
   function getEmployee(uint256 employeeId) constant returns (address employee); // Return all important info too
 
   function calculatePayrollBurnrate() constant returns (uint256); // Monthly EUR amount spent in salaries
   function calculatePayrollRunway() constant returns (uint256); // Days until the contract can run out of funds
 
   /* EMPLOYEE ONLY */
   function determineAllocation(address[] tokens, uint256[] distribution); // only callable once every 6 months
   function payday(); // only callable once a month
 
   /* ORACLE ONLY */
   function setExchangeRate(address token, uint256 EURExchangeRate); // uses decimals from token
}
