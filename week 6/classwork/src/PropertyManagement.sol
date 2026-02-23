// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

contract PropertyManagement {

    constructor() {
        owner = msg.sender;
    }

    struct Property {
        uint8 id;
        string propertyName;
        string propertyDescription;
        uint256 propertyPrice;
    }  
    address public  owner;

    error NOT_THE_OWNER();

    modifier ONLY_OWNER() {
        if (owner != msg.sender) {
        revert NOT_THE_OWNER();
        }
        _;
    }
    uint8 propertyId;

    Property[] public properties;

    function createProperty( string memory _name, string memory _description, uint256 _price) public {
        propertyId = propertyId + 1 ;

        Property memory property = Property({ id : propertyId, propertyName: _name, propertyDescription: _description, propertyPrice: _price });

        properties.push(property);

    }

    function getAllProperties() external  view returns(Property[] memory) {
        return properties;
    }

    function removeProperty(uint8 _id) public ONLY_OWNER {
        for (uint8 i; i < properties.length; i++) 
        {
            if(properties[i].id == _id) {
            properties[i] = properties[properties.length - 1];
            properties.pop();
            break;
            }

        
        }
    }

}