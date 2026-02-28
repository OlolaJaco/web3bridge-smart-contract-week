// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {MyERC20} from "./MyERC20.sol";


contract SchoolManagementSystem {


    MyERC20 public token;

    //mapping level to level fee
    mapping (uint16 => uint) levelFees;

    constructor( address _tokenAddress ) {
        levelFees[100] = 100;
        levelFees[200] = 200;
        levelFees[300] = 300;
        levelFees[400] = 400;
        token = MyERC20(_tokenAddress);
    }

    struct Student {
        uint8 id;
        string name;
        uint schoolFess;
        bool hasPaid;
        uint timeStamp;
        uint level;
    }

    struct Staff {
        uint id;
        string name;
        uint salary;
        string registeredAt;
    }
    

    //Array of students
    Student[] public students;

    //Array of staff
    Staff[] public staffs;

    // declaring student ID
    uint8 student_id;

    // declaring staff ID
    uint8 staff_ID;

    uint fees;


    event StudentRegistered(uint8 indexed id, string name, uint fees, bool hasPaid, uint level);

    // student registration
    function registerStudent( string memory _name, uint16 _level ) public payable {
        require(
            _level == 100 || _level == 200 || _level == 300 || _level == 400,
            "Invalid level. Must be 100, 200, 300, or 400"
        );

        fees = levelFees[_level];

        uint8 id = student_id + 1;

        bool success = token.transferFrom(msg.sender, address(this), fees);
        require(success, "Transfer failed");

        //creating individual students
        Student memory student = Student({ id: id, name: _name, hasPaid: true, timeStamp: block.timestamp, level: _level, schoolFess: fees });
        students.push(student);
        student_id = student_id + 1;

        emit StudentRegistered(id, _name, fees, true, _level);
    }

    function getAllStudents() external view returns(Student[] memory) {
        return students;
    }


    // staff registration
    function registerStaff(string memory _name) public {
        uint8 id = staff_ID + 1;

        Staff memory staff = Staff({ id: id, name: _name, salary: 0, registeredAt: ""});
        staffs.push(staff);
        staff_ID = staff_ID + 1;
    }

    function payStaff ( uint _id ) payable public {
        for ( uint8 i; i < staffs.length; i++) {
            if (staffs[i].id == _id) {
                bool success = token.transfer(msg.sender, 5);
                require(success);
                break;
            }
        }
    }

    function getAllStaff() external view returns(Staff[] memory) {
        return staffs;
    }

    // fetch contract balance 
    function getContractBalance( ) public view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {  }
    fallback() external payable {  }
}