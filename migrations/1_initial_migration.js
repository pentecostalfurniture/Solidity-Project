var Scheduler = artifacts.require("./Scheduler.sol");
var Payroll = artifacts.require("./Payroll.sol");

module.exports = function(deployer) {
  deployer.deploy(Scheduler);
  deployer.deploy(Payroll);
};
