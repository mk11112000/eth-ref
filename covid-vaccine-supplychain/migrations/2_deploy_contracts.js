const supplyChain = artifacts.require("supplyChain");

module.exports = function(deployer) {
  deployer.deploy(supplyChain);
};
