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

   function ()payable public {
   }

   function getBalance() public view onlyOwner returns (uint256) {
       return address(this).balance;
   }

   struct Employee {
        bool isEmployee;
        address[] allowedTokens;
        uint256 monthlyEURSalary;
   }

   mapping(address => Employee) private employees;
   uint256 employeeCount;

   function isEmployee(address employeeAddress) public view returns (bool) {
       return employees[employeeAddress].isEmployee;
   }

   function getEmployeeCount() public view returns (uint256) {
       return employeeCount;
   }

   function addEmployee(
       address accountAddress,
       address[] allowedTokens,
       uint256 initialMonthlyEURSalary
   )
       public
       onlyOwner
   {
       require(!employees[accountAddress].isEmployee);
       employees[accountAddress].allowedTokens = allowedTokens;
       employees[accountAddress].monthlyEURSalary = initialMonthlyEURSalary;
       employees[accountAddress].isEmployee = true;
       employeeCount++;
   }

   function removeEmployee(address accountAddress) public onlyOwner {
       delete employees[accountAddress];
       employeeCount--;
   }

   function setEmployeeSalary(
       address accountAddress,
       uint256 monthlyEURSalary
   ) 
       public
       onlyOwner
   {
       employees[accountAddress].monthlyEURSalary = monthlyEURSalary;
   }

   function scapeHatch();
   // function addTokenFunds()? // Use approveAndCall or ERC223 tokenFallback

   function getEmployeeInfo(
       address accountAddress
   )
       public
       onlyOwner
       view
       returns (bool,
                address[],
                uint256) {
       return (employees[accountAddress].isEmployee,
               employees[accountAddress].allowedTokens,
               employees[accountAddress].monthlyEURSalary);
   }

   function calculatePayrollBurnrate() constant returns (uint256); // Monthly EUR amount spent in salaries
   function calculatePayrollRunway() constant returns (uint256); // Days until the contract can run out of funds
 
   /* EMPLOYEE ONLY */
   function determineAllocation(address[] tokens, uint256[] distribution); // only callable once every 6 months
   function payEmployee(address accountAddress) public onlyOwner {
        // TODO: make this callable only once a month for each employee
        require(employees[accountAddress].isEmployee);
        accountAddress.transfer(employees[accountAddress].monthlyEURSalary);
   }
 
   /* ORACLE ONLY */
   function setExchangeRate(address token, uint256 EURExchangeRate); // uses decimals from token
}
