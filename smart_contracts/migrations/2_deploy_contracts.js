// migrating the appropriate contracts
var BatteryUserRole = artifacts.require("./BatteryUserRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(BatteryUserRole);
  deployer.deploy(SupplyChain);
};
