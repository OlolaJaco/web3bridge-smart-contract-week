// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {MyERC20} from "./MyERC20.sol";

contract SchoolManagementRedo {
    struct Student {
        uint8 id;
        string name;
        bool hasPaid;
        uint16 schoolFees;
        uint createdAt;
    }

    struct Staff {
        uint8 id;
        string name;
        bool salaryIsPaid;
        uint16 salary;
        uint createdAt;
    }

    Student[] public students;

    Staff[] public staffs;

    uint8 studentId;

    uint8 staffId;

    // mapping(address => uint) public students;

    mapping(uint16 => uint16) public pricePerLevel;

    MyERC20 public token;

    event Registered( uint8 indexed id, string indexed name);

    constructor(address _tokenAddress) {
        pricePerLevel[100] = 150;
        pricePerLevel[200] = 250;
        pricePerLevel[300] = 350;
        pricePerLevel[400] = 450;
        token = MyERC20(_tokenAddress);
    }

    function registerStudent(string calldata _name, uint8 _level) public {
        require(
            _level == 100 || _level == 200 || _level == 300 || _level == 400,
            "Invalid leve, level should be 100, 200, 300, or 400."
        );

        uint8 id = studentId + 1;

        require(msg.sender != address(0), "Can send to account zero");
        uint16 amount = pricePerLevel[_level];

        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transaction failed"
        );

        Student memory student = Student({
            id: id,
            name: _name,
            hasPaid: true,
            schoolFees: amount,
            createdAt: block.timestamp
        });

        students.push(student);

        id = studentId + 1;

        emit Registered(id, _name );
    }

    function registerSaff(string calldata _name) public {
        uint8 id = staffId + 1;

        Staff memory staff = Staff({
            id: id,
            name: _name,
            salaryIsPaid: false,
            salary: 0,
            createdAt: block.timestamp
        });

        staffs.push(staff);

        id = id + 1;
    }

    function payStaff( uint8 _id, uint8 _salary ) public {

        for (uint8 i; i < staffs.length; i++) 
        {
            if (staffs[i].id == _id) {
                staffs[i].salary = _salary;
            require(address(this).balance >= _salary, "Insuffient funds");
            require(token.transfer( msg.sender, _salary));
            break ;

            }

        }
    }


    function getAllStaffs() public  view returns(Staff[] memory) {
        return staffs;
    }

    function getAllStudents() public view returns(Student[] memory) {
        return students;
    }


    receive() external payable { }
    fallback() external payable { }
}
