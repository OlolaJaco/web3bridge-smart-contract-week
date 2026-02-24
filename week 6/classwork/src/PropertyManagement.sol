// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;
import {IERC20} from './IERC20.sol';

contract PropertyManagement {

    // token_address=0x78c4E798b65f1c96c4eEC6f5F93E51584593e723
    IERC20 token;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
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

         propertyId = propertyId + 1 ;

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
            }
        }
    }

    function sellProperty( uint8 _id, address _buyerAddress, uint256 _value ) public ONLY_OWNER {
        for (uint8 i; i < properties.length; i++) 
        {
            if(properties[i].id == _id) {

                require(msg.sender != address(0), "Invalid address type");

                require(properties[i].propertyPrice == _value, "check the produce price and use it"); 
                
                token.transfer(_buyerAddress, _value);
            } 
        }
    }

    function buyProperty(uint256 id_, uint256 value_) public {
        for (uint8 i; i < properties.length; i++) 
        {
            if(properties[i].id == id_) {

        require(token.balanceOf(msg.sender) >= value_, "insufficient funds");

                require(properties[i].propertyPrice == value_, "check the produce price and use it"); 
                
                token.transferFrom(msg.sender, address(this), value_);
            } 
        }
    }

}