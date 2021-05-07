// SPDX-License-Identifier: MIT
// Deployed at 0xae0894DACee848D8b2cC0d9686050a0055CdB455 on Goerli
pragma solidity ^0.8.0;

contract Counter {
    // storage
    mapping(address => bool) _owners;
    mapping(address => bool) _coOwners;
    uint256 private _counter;
    uint256 private _step;

    // constructor
    constructor(uint256 step_, address coAccount) {
        _owners[msg.sender] = true;
        _coOwners[coAccount] = true;
        _step = step_;
    }

    // writing functions
    function increment() public {
        _counter += _step;
    }

    function reset() public {
        require(
            _owners[msg.sender] == true,
            "SecretMessage: Only owners can reset the counter"
        );
        _counter = 0;
    }

    function decrement() public {
        require(
            (_owners[msg.sender] == true || _coOwners[msg.sender] == true) &&
                _counter != 0,
            "SecretMessage: Only owners and coOwners can decrement the counter and only if counter stay positive"
        );
        _counter -= _step;
    }

    function addOwners(address account) public {
        require(
            _owners[msg.sender] == true,
            "SecretMessage: Only owners can add others owners"
        );
        _owners[account] = true;
    }

    function setStep(uint256 step_) public {
        require(
            _owners[msg.sender] == true,
            "SecretMessage: Only owners can add others owners"
        );
        _step = step_;
    }

    // view functions
    function step() public view returns (uint256) {
        return _step;
    }

    function counter() public view returns (uint256) {
        return _counter;
    }

    function isOwners(address account) public view returns (bool) {
        return _owners[account];
    }

    function isCoOwners(address account) public view returns (bool) {
        return _coOwners[account];
    }
}
