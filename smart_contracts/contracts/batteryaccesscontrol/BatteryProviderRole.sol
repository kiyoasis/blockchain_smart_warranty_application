pragma solidity ^0.4.24;

import "./Roles.sol";

contract BatteryProviderRole {

    // Define 2 events, one for Adding, and other for Removing
    event AddBatteryProvider(address _account);
    event RemoveBatteryProvider(address _account);

    // Define a struct 'BatteryProvider' by inheriting from 'Roles' library, struct Role
    using Roles
    for Roles.Role;
    Roles.Role batteryProvider;

    constructor() public { }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyBatteryProvider(address _provider) {
        require(msg.sender == _provider);
        _;
    }

    // Define a function 'isBatteryProvider' to check this role
    function isBatteryProvider(address _account) public view returns(bool) {
        if (msg.sender == _account) {
            return true;
        } else {
            return false;
        }
    }

    // Define a function 'addBatteryProvider' that adds this role
    function addBatteryProvider(address _account) public {
        _addBatteryProvider(_account);
        emit AddBatteryProvider(_account);
    }

    // Define a function 'removeBatteryProvider' to remove this role
    function removeBatteryProvider(address _account) public {
        _removeBatteryProvider(_account);
        emit RemoveBatteryProvider(_account);
    }

    // Define an internal function '_addBatteryProvider' to add this role, called by 'addBatteryProvider'
    function _addBatteryProvider(address _account) internal {
        batteryProvider.add(_account);
    }

    // Define an internal function '_removeBatteryProvider' to remove this role, called by 'removeBatteryProvider'
    function _removeBatteryProvider(address _account) internal {
        batteryProvider.remove(_account);
    }

}