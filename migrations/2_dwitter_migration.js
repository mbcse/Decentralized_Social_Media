const dwitter = artifacts.require("Dwitter");

module.exports = function (deployer) {
  deployer.deploy(dwitter);
};
