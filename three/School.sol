// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMyERC20 {
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract School {
    address public owner;
    IMyERC20 public token;

    struct Student {
        address studentAddress;
        string name;
        uint level;
        uint fee;
        bool hasPaid;
        uint paidAt;
        bool exists;
    }

    struct Staff {
        address staffAddress;
        string name;
        string role;
        uint salary;
        uint lastPaidAt;
        bool exists;
    }

    mapping(address => Staff) private staffs;
    address[] private staffList;

    mapping(address => Student) private students;
    address[] private studentList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IMyERC20(_tokenAddress);
    }

    function getFeeByLevel(uint _level) public pure returns (uint256) {
        if (_level == 100) return 100;
        if (_level == 200) return 200;
        if (_level == 300) return 300;
        if (_level == 400) return 400;
        revert("Invalid Level");
    }

    function registerStudent(string memory _name, uint _level) external {
        require(!students[msg.sender].exists, "Already registered");

        uint fee = getFeeByLevel(_level);

        bool success = token.transferFrom(msg.sender, address(this), fee);
        require(success, "Payment failed");

        students[msg.sender] = Student({
            studentAddress: msg.sender,
            name: _name,
            level: _level,
            fee: fee,
            hasPaid: true,
            paidAt: block.timestamp,
            exists: true
        });

        studentList.push(msg.sender);
    }

    function getStudent(address _studentAddress)
        public
        view
        returns (
            address,
            string memory,
            uint,
            uint,
            bool,
            uint
        )
    {
        require(students[_studentAddress].exists, "Student not found");

        Student memory s = students[_studentAddress];
        return (
            s.studentAddress,
            s.name,
            s.level,
            s.fee,
            s.hasPaid,
            s.paidAt
        );
    }

    function getAllStudents() public view returns (address[] memory) {
        return studentList;
    }

    function registerStaff(
        address _staffAddress,
        string memory _name,
        string memory _role,
        uint _salary
    ) public onlyOwner {
        require(_staffAddress != address(0), "Address zero detected");
        require(!staffs[_staffAddress].exists, "Staff already registered");
        require(_salary > 0, "Salary must be greater than zero");

        staffs[_staffAddress] = Staff({
            staffAddress: _staffAddress,
            name: _name,
            role: _role,
            salary: _salary,
            lastPaidAt: 0,
            exists: true
        });

        staffList.push(_staffAddress);
    }

    function getStaff(address _staffAddress)
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint,
            uint
        )
    {
        require(staffs[_staffAddress].exists, "Staff not found");

        Staff memory s = staffs[_staffAddress];
        return (
            s.staffAddress,
            s.name,
            s.role,
            s.salary,
            s.lastPaidAt
        );
    }

    function payStaff(address _staffAddress) public onlyOwner {
        require(staffs[_staffAddress].exists, "Staff not found");

        Staff storage s = staffs[_staffAddress];

        require(token.balanceOf(address(this)) >= s.salary, "Not enough tokens");

        bool success = token.transfer(s.staffAddress, s.salary);
        require(success, "Token transfer failed");

        s.lastPaidAt = block.timestamp;
    }
}