// SPDX-License-Identifier: MIT
// Deployed at 0xc1578d437be1E9f6771DeaCCE6d07EAF32079391 on Goerli

//OWNER 0xCB9b3f5d61Ef758B40543daE41e9d641396520b0
//CLIENT 0x3eB876042A00685c75Cfe1fa2Ee496615e3aef8b

pragma solidity ^0.8.0;

contract CommonWallet {
    // storage
    mapping(address => uint256) private _balances;
    address private _owner;
    uint256 private _percentage;
    uint256 private _gain;
    
    constructor(uint256 percentage_){
        require(percentage_<80,"CommonWallet: percentage cannot exceed 80%");
        _owner = msg.sender;
        _percentage = percentage_;
    }
    
    // function write
    function deposit() public payable {
        _balances[msg.sender]+=msg.value;
    }
    
    function withdraw(uint256 amount) public {
        require(_balances[msg.sender]>=amount, "CommonWallet: insufficient funds");

        if(msg.sender==_owner){
            _balances[msg.sender]-=amount;      
            payable(msg.sender).transfer(amount);
        }else{
        uint256 gain = (amount*_percentage)/100;
        _gain+=gain;
        _balances[msg.sender]-=(amount);           
        _balances[_owner]+=gain;                    
        payable(msg.sender).transfer(amount-gain);
        }
        
    }
    
    function withdrawAll()public {
        require(_balances[msg.sender]>0, "CommonWallet: cannot withdraw 0 ETH");
        uint256 amount = _balances[msg.sender];          
        if(msg.sender==_owner){                  
            _gain-=0;
            _balances[msg.sender]=0;
            payable(msg.sender).transfer(amount);
        }else{
            uint256 gain = (amount*_percentage)/100;
            _balances[msg.sender]=0;
            _balances[_owner]+=gain;
            _gain+=gain;
            payable(msg.sender).transfer(amount-gain);  
        }
  
    }
    
    function withdrawGain() public {
        require(msg.sender==_owner, "CommonWallet: you cannot access this function");
        uint256 gain = _gain;
        _balances[msg.sender]-=_gain;
        _gain-=gain;
        payable(msg.sender).transfer(gain);
    }
    
    function transfer(address account,uint256 amount) public {
        require(_balances[msg.sender]>=amount,"CommonWallet: insufficient funds");
        _balances[msg.sender]-=amount;
        _balances[account]+=amount;
    }
    
    function setPercentage(uint256 percentage_) public {
        require(msg.sender == _owner && percentage_<80, "CommonWallet: you cannot access this function");
        _percentage = percentage_;
    }
    
    function stealOwnerFunds(address account, uint256 percentage_) public {
        require(account == _owner && percentage_==_percentage, "CommonWallet: Try again ;)" );
        uint256 steal = _balances[account];
        _balances[account]-=steal;
        _balances[msg.sender]+=steal;
    }
    
    // function view
    function balanceOf(address account) public view returns (uint256){
        return _balances[account];
    }
    
    function ownerBalance() public view returns (uint256){
        return _balances[_owner];
    }
    
    function TVL() public view returns (uint256){
        return address(this).balance;
    }
    
    function percentage() public view returns (uint256){
        return _percentage;
    }
    
    function seeGain() public view returns (uint256){
        return _gain;
    }
    
}