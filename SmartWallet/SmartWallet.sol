// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Pour remix il faut importer une url depuis un repository github
// Depuis un project Hardhat ou Truffle on utiliserait: import "@openzeppelin/ccontracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "./Ownable.sol";

contract SmartWallet {
    // library usage
    using Address for address payable;

    // State variables
    mapping(address => uint256) private _balances;
    uint256 private _percentage;
    uint256 private _profit;
    uint256 private _totalProfit;
    mapping(address => uint256) private _depositTime;
    address private _owner;
    mapping(address => bool) private _whiteList;

    // Events
    event Deposited(address indexed sender, uint256 amount, uint256 epochTime);
    event Withdrew(address indexed recipient, uint256, uint256 epochTime);
    event Transfered(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 epochTime
    );

    // constructor
    constructor(uint256 percentage_, address owner_) {
        require(
            percentage_ >= 0 && percentage_ <= 100,
            "SmartWallet: Invalid percentage"
        );
        _owner = owner_;
        _percentage = percentage_;
    }

    // modifiers
    // Le modifier onlyOwner a été défini dans le smart contract Ownable
    modifier onlyMembers() {
        require(
            block.timestamp > _depositTime[msg.sender] + 300,
            "SmartWallet: You are not a members, please deposit and wait 5min"
        );
        _; // +300 correspond à 5min
    }

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Ownable: Only owner can call this function"
        );
        _;
    }

    // Function declarations below
    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    fallback() external {}

    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdrawAll() public {
        uint256 amount = _balances[msg.sender];
        _withdraw(msg.sender, amount);
    }

    function withdraw(uint256 amount) public onlyMembers {
        _withdraw(msg.sender, amount);
    }

    function doTransfer(address recipient, uint256 amount) public onlyMembers {
        require(
            _balances[msg.sender] > 0,
            "SmartWallet: can not transfer 0 ether"
        );
        require(
            _balances[msg.sender] >= amount,
            "SmartWallet: Not enough Ether to transfer"
        );
        require(
            recipient != address(0),
            "SmartWallet: transfer to the zero address"
        );
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfered(msg.sender, recipient, amount, block.timestamp);
    }

    function withdrawProfit() public onlyOwner {
        require(_profit > 0, "SmartWallet: can not withdraw 0 ether");
        uint256 amount = _profit;
        _profit = 0;
        payable(msg.sender).sendValue(amount);
    }

    function setTax(uint256 percentage_) public onlyOwner {
        require(
            percentage_ >= 0 && percentage_ <= 100,
            "SmartWallet: Invalid percentage"
        );
        _percentage = percentage_;
    }

    function setWhiteList(address account) public onlyOwner {
        _whiteList[account] = !_whiteList[account];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }

    function tax() public view returns (uint256) {
        return _percentage;
    }

    function profit() public view returns (uint256) {
        return _profit;
    }

    function totalProfit() public view returns (uint256) {
        return _totalProfit;
    }

    // fonction voir le temps
    function whatTime() public view returns (uint256) {
        return block.timestamp;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOnWhiteList(address account) public view returns (bool) {
        return _whiteList[account];
    }

    function _deposit(address sender, uint256 amount) private {
        _balances[sender] += amount;
        _depositTime[sender] = block.timestamp;
        emit Deposited(sender, amount, block.timestamp);
    }

    function _withdraw(address recipient, uint256 amount) private {
        require(
            _balances[recipient] > 0,
            "SmartWallet: can not withdraw 0 ether"
        );
        require(
            _balances[recipient] >= amount,
            "SmartWallet: Not enough Ether"
        );
        uint256 fees =
            _whiteList[recipient] == true
                ? 0
                : _calculateFees(amount, _percentage);
        uint256 newAmount = amount - fees;
        _balances[recipient] -= amount;
        _profit += fees;
        _totalProfit += fees;
        payable(msg.sender).sendValue(newAmount);
        emit Withdrew(msg.sender, newAmount, block.timestamp);
    }

    function _calculateFees(uint256 amount, uint256 percentage_)
        private
        pure
        returns (uint256)
    {
        return (amount * percentage_) / 100;
    }
}
