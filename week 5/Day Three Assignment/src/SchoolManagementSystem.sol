// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "./MyERC20.sol";


contract SchoolManagementSystem {

    MyERC20 public token;

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
    function registerStudent( string memory _name, uint _level ) public payable {
        require(
            _level == 100 || _level == 200 || _level == 300 || _level == 400,
            "Invalid level. Must be 100, 200, 300, or 400"
        );

        uint8 id = student_id + 1;

        if ( _level == 100 ) {
            fees = 10;
        } else if ( _level == 200 ) {
            fees = 20;
        } else if ( _level == 300 ) {
            fees = 30;
        } else if ( _level == 400 ) {
            fees = 40;
        }

        fees = msg.value;

        //creating individual students
        Student memory student = Student({ id: id, name: _name, hasPaid: true, timeStamp: block.timestamp, level: _level, schoolFess: fees });
        students.push(student);
        student_id = student_id + 1;

        emit StudentRegistered(id, _name, fees, true, _level);
    }

    function paySchoolFees(address _student) public payable  {
        token.transfer(_student, fees);
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
                token.transfer(msg.sender, 5);
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