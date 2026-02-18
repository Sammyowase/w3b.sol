// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
}

contract SavingsVault {

    
    mapping(address => uint256) public etherSavings;

    mapping(address => mapping(address => uint256)) public tokenSavings;
 

    event EtherDeposited(address indexed user, uint amount);
    event EtherWithdrawn(address indexed user, uint amount);

    event TokenDeposited(address indexed user, address indexed token, uint amount);
    event TokenWithdrawn(address indexed user, address indexed token, uint amount);

  

    function depositEther() external payable {
        require(msg.value > 0, "Send ETH");

        etherSavings[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }

    function withdrawEther(uint amount) external {
        require(etherSavings[msg.sender] >= amount, "Not enough saved");

        etherSavings[msg.sender] -= amount;
       (bool success, ) = payable(msg.sender).call{value: amount}("");
       
        require(success, "ETH transfer failed");


        emit EtherWithdrawn(msg.sender, amount);
    }

    function getEtherBalance(address user) external view returns (uint) {
        return etherSavings[user];
    }



    function depositToken(address token, uint amount) external {
        require(amount > 0, "Amount must be > 0");

        
        bool success = ERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        tokenSavings[msg.sender][token] += amount;

        emit TokenDeposited(msg.sender, token, amount);
    }

    function withdrawToken(address token, uint amount) external {
        require(tokenSavings[msg.sender][token] >= amount, "Not enough token saved");

        tokenSavings[msg.sender][token] -= amount;

        bool success = ERC20(token).transfer(msg.sender, amount);
        require(success, "Transfer failed");

        emit TokenWithdrawn(msg.sender, token, amount);
    }

    function getTokenBalance(address user, address token) external view returns (uint) {
        return tokenSavings[user][token];
    }
}
