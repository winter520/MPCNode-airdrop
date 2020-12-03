// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    address public owner;
    IERC20 public token;
    mapping (address => uint256) public airdrops;

    event OwnershipTransferred(address indexed _old, address indexed _new);
    event SetValue(address indexed _user, uint256 indexed _amount);
    event Claim(address indexed _user, uint256 indexed _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(IERC20 _token) public {
        token = _token;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function register(address _user) public onlyOwner {
        require(_user != address(0), "zero address");
        airdrops[_user] = 1;
    }

    function registered(address _user) public view returns (bool) {
        return airdrops[_user] > 0;
    }

    function setValue(address _user, uint256 _amount) public onlyOwner {
        require(_amount > 1, "invalid value");
        require(airdrops[_user] == 1, "invalid status");
        airdrops[_user] = _amount;
        emit SetValue(_user, _amount);
    }

    function claim() public returns (bool) {
        uint256 amount = airdrops[msg.sender];
        require(amount > 1, "no value");
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "not enough balance");
        airdrops[msg.sender] = 1;
        assert(token.transfer(msg.sender, amount));
        emit Claim(msg.sender, amount);
        return true;
    }
}
