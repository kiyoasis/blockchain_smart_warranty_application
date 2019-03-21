pragma solidity ^0.4.24;

import "./Roles.sol";

contract EMSProviderRole {

    // Define 2 events, one for Adding, and other for Removing
    event AddEMSProvider(address _account);
    event RemoveEMSProvider(address _account);

    // Define a struct 'EMSProvider' by inheriting from 'Roles' library, struct Role
    using Roles
    for Roles.Role;
    Roles.Role emsProvider;

  // EMS Provider information: need to be approved by the battery provider
  // struct EnergyManagementSystemProvider {
  //     address emsProvider;
  //     bool isApproved;
  // }

    constructor() public {

    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyEMSProvider(address _emsProvider) {
        require(msg.sender == _emsProvider);
        _;
    }

    // Define a function 'isEMSProvider' to check this role
    function isEMSProvider(address _account) public view returns(bool) {
        if (msg.sender == _account) {
            return true;
        } else {
            return false;
        }
    }

    // Define a function 'addEMSProvider' that adds this role
    function addEMSProvider(address _account) public {
        _addEMSProvider(_account);
        emit AddEMSProvider(_account);
    }

    // Define a function 'removeEMSProvider' to remove this role
    function removeEMSProvider(address _account) public {
        _removeEMSProvider(_account);
        emit RemoveEMSProvider(_account);
    }

    // Define an internal function '_addEMSProvider' to add this role, called by 'addEMSProvider'
    function _addEMSProvider(address _account) internal {
        emsProvider.add(_account);
    }

    // Define an internal function '_removeEMSProvider' to remove this role, called by 'removeEMSProvider'
    function _removeEMSProvider(address _account) internal {
        emsProvider.remove(_account);
    }

}