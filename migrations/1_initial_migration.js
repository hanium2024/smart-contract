const Migrations = artifacts.require("Migrations");
const MyNFT = artifacts.require("HappyMaru");
module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(MyNFT);
};
