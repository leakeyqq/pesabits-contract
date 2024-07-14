// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;
// Import the ownable smart contract 
import "@openzeppelin/contracts/access/Ownable.sol";
// Prevent reentrancy attacks
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/*
* This contract will be holding user assets after the make a deposit to Pesabits
* When a user request a withdrawal. It will be made form this contract
*/
contract PesabitsContract is Ownable, ReentrancyGuard {

    constructor() Ownable(msg.sender) {}

    // Receive and accept deposits from native tokens
    receive() external payable {}

    // Event fires after a withdrawal has been made from the smart contract
    event UserWithdrewNativeToken(address recipient, uint256 amount);
    event UserWithdrewErc20Token(address recipient, address tokenAddress, uint256 amount);

    /// @dev BNB is the native token in BSC. The same will apply when this contract is deployed in another chain
    function user_withdraw_nativeToken(address payable _recipient, uint256 _amount) external onlyOwner nonReentrant {

        // Check that smart contract has enough balance
        require(address(this).balance >= _amount, 'Insufficient balance in contract');

        // Do the transfer
        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Transfer failed.");

        // Emit the transfer event
        emit UserWithdrewNativeToken(_recipient, _amount);
    }

    /// @dev Whitelist all erc20 token addresses. Some contracts might be dangerous to interact with
    function user_withdraw_erc20Token(address payable _recipient, uint256 _amount, address _tokenAddress) external onlyOwner nonReentrant{

        // Instantiate the erc20 token
        IERC20 token_to_withdraw = IERC20(_tokenAddress);
        
        // Check if there is enough balance
        require(token_to_withdraw.balanceOf(address(this)) >= _amount);

        // Call the transfer function
        require(token_to_withdraw.transfer(_recipient, _amount), 'Transfer failed'); 

        // Emit the transfer event
        emit UserWithdrewErc20Token(_recipient, _tokenAddress,  _amount);
        
    }
}