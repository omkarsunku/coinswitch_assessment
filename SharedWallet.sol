// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SharedWallet {
    // address of the admin user
    address public admin;
    // array to store authorized users
    address[] usersKeys;
    // struct to store user's information
    struct User {
        uint256 allowance;
        bool authorized;
        uint256 expires;
    }
    // mapping of users' information
    mapping(address => User) public users;
    // events for when funds are added, spent, and authorization changed
    event LogFundsAdded(address user, uint256 amount);
    event LogFundsSpent(address user, uint256 amount);
    event LogAuthorizationChanged(address user, bool authorized);

    // constructor function
    constructor() {
        // set the admin user to the deployer of the contract
        admin = msg.sender;
    }

    // function to add funds
    function addFunds() public payable {
        // check that the sender is the admin and a positive value is being added
        require(msg.sender == admin, "Only admin can add funds.");
        require(msg.value > 0, "Amount must be greater than 0.");
        // emit event
        emit LogFundsAdded(msg.sender, msg.value);
    }

    // function to set allowance and authorize a user
    function allowanceAndAuthorize(
        address user,
        uint256 allowance,
        uint256 expires
    ) public {
        // check that the sender is the admin
        require(msg.sender == admin, "Only admin can authorize users.");
        // check that allowance is greater than 0 and expires timestamp is in the future
        require(allowance > 0, "Allowance must be greater than 0.");
        require(expires > block.timestamp, "Expiration must be in the future.");
        // set user's information
        users[user].allowance = allowance;
        users[user].authorized = true;
        users[user].expires = expires;
        // push user's address in the usersKeys array
        usersKeys.push(user);
        // emit event
        emit LogAuthorizationChanged(user, true);
    }

    // function to revoke user's authorization
    function revoke(address user) public {
        // check that the sender is the admin
        require(msg.sender == admin, "Only admin can revoke authorization.");
        // check that the user is authorized
        require(users[user].authorized, "User is not authorized.");
        // set user's information
        users[user].authorized = false;
        users[msg.sender].allowance = 0;
        // emit event
        emit LogAuthorizationChanged(user, false);
    }

    // function to spend funds
    function spend(address payable to, uint256 amount) public {
        if (msg.sender == admin) {
            // check that there are enough funds
            require(amount <= getBalance(), "Insufficient funds.");
            // transfer the funds
            to.transfer(amount);
        } else {
            // check that the user is authorized
            require(users[msg.sender].authorized, "Sender is not authorized.");
            // check that the user has enough allowance
            require(
                users[msg.sender].allowance >= amount,
                "Allowance exceeded."
            );
            // check that the user time limit has expired
            require(
                block.timestamp < users[msg.sender].expires,
                "Authorization has expired."
            );
            // check that there are enough funds
            require(amount <= getBalance(), "Insufficient funds.");
            // transfer the funds
            to.transfer(amount);
            // update user's allowance
            users[msg.sender].allowance -= amount;
        }
        // emit event
        emit LogFundsSpent(msg.sender, amount);
    }

    // function to current getBalance in the contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // function to check the user expiry and update the information if limit exceeded
    function checkExpirations() public {
        for (uint256 i = 0; i < usersKeys.length; i++) {
            address user = usersKeys[i];
            if (block.timestamp >= users[user].expires) {
                //revoke authorization
                users[user].authorized = false;
                users[user].allowance = 0;
                //emit event
                emit LogAuthorizationChanged(user, false);
            }
        }
    }
}
