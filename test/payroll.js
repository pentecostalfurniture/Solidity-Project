var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  var pay;
  it("should have one employee after adding one employee", function() {
    return Payroll.deployed().then(function(instance) {
      pay = instance;
      return instance.addEmployee(accounts[1], [], 12, {from: accounts[0]});
    }).then(function() {
      return pay.employeeCount.call();
    }).then(function(employeeCount) {
      assert.equal(employeeCount.toNumber(), 1, "Employee count should be 1");
    });
  });
});
