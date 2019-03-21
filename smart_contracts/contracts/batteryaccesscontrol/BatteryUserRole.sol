pragma solidity ^ 0.4 .24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'BatteryUserRole' to manage this role - add, remove, check
contract BatteryUserRole {

    // Define 2 events, one for Adding, and other for Removing
    event AddBatteryUser(address _account);
    event RemoveBatteryUser(address _account);

    // Define a struct 'BatteryUser' by inheriting from 'Roles' library, struct Role
    using Roles
    for Roles.Role;
    Roles.Role batteryUser;

    // struct BatteryUser {
    //   string ownerID;
    //   string firstName;
    //   string lastName;
    //   string companyName;
    // }

    // uint userId = 1;
    // mapping(uint => address) userIdToAddress;

    // In the constructor make the address that deploys this contract the 1st consumer
    constructor() public {

    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyBatteryUser(address _user) {
        require(msg.sender == _user);
        _;
    }

    // Define a function 'isBatteryUser' to check this role
    function isBatteryUser(address _account) public view returns(bool) {
        if (msg.sender == _account) {
            return true;
        } else {
            return false;
        }
    }

    // Define a function 'addBatteryUser' that adds this role
    function addBatteryUser(address _account) public {
        // userIdToAddress[userId] = _account;
        // userId++;
        _addBatteryUser(_account);
        emit AddBatteryUser(_account);
    }

    // Define a function 'removeBatteryUser' to remove this role
    function removeBatteryUser(address _account) public {
        _removeBatteryUser(_account);
        emit RemoveBatteryUser(_account);
    }

    // Define an internal function '_addBatteryUser' to add this role, called by 'addBatteryUser'
    function _addBatteryUser(address _account) internal {
        batteryUser.add(_account);
    }

    // Define an internal function '_removeBatteryUser' to remove this role, called by 'removeBatteryUser'
    function _removeBatteryUser(address _account) internal {
        batteryUser.remove(_account);
    }
}