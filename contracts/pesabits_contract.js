var PesabitsContract = artifacts.require('./PesabitsContract.sol')
module.exports = function(deployer) {
    deployer.deploy(PesabitsContract)
}