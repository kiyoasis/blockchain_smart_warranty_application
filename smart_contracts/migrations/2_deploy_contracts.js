// migrating the appropriate contracts
var BatteryUserRole = artifacts.require("./BatteryUserRole.sol");
var BatteryProviderRole = artifacts.require("./BatteryProviderRole.sol");
var EMSProviderRole = artifacts.require("./EMSProviderRole.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(BatteryUserRole);
  deployer.deploy(BatteryProviderRole);
  deployer.deploy(EMSProviderRole);
  deployer.deploy(SupplyChain);
};
