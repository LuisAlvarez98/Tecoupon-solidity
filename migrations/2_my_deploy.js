const Tecoupons = artifacts.require('Tecoupons');

module.exports = async function (deployer) {
  await deployer.deploy(Tecoupons);
};
