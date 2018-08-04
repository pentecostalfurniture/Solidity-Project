pragma solidity ^0.4.7;
// For the sake of simplicity lets assume EUR is a ERC20 token
// Also lets assume we can 100% trust the exchange rate oracle
contract Fund {
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
}

contract Payroll is Fund {
   struct Employee {
        bool isEmployee;
        address[] allowedTokens;
        uint256 monthlyEURSalary;
   }

   mapping(address => Employee) private employees;
   uint256 employeeCount;
   uint256 monthlyDisbursement;

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
       monthlyDisbursement += initialMonthlyEURSalary;
   }

   function removeEmployee(address accountAddress) public onlyOwner {
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
       public
       onlyOwner
   {
       uint256 oldSalary = employees[accountAddress].monthlyEURSalary;
       employees[accountAddress].monthlyEURSalary = monthlyEURSalary;
       monthlyDisbursement = monthlyDisbursement - oldSalary + monthlyEURSalary;
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

   function payrollBurnrate() public view returns (uint256) {
        // Monthly EUR amount spent in salaries
        return monthlyDisbursement;
   }

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
