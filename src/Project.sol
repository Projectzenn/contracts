// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract ProjectContract is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Define roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");

    // Project information
    struct Project {
        string name;
        string description;
        uint256 deadline; // timestamp for project completion
        string url; // URL to the project <- can be mumbai polyogn scanner 
    }
    Project public project;
    

    // Members
    EnumerableSet.AddressSet private members;

    // Works
    struct Work {
        uint256 milestoneIndex;
        string description;
        address assignee; // Member assigned to this work
        WorkStatus status;
    }
    
    Work[] public works;

    enum WorkStatus {
        PENDING,
        IN_PROGRESS,
        COMPLETED
    }

    // Milestones
    struct Milestone {
        string description;
        uint256 deadline;
        bool completed;
        address submitter; 
        uint256 approvalVotes;
    }
    Milestone[] public milestones;

    // Events
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event ProjectUpdated(string name, string description, uint256 deadline, string url);
    event MilestoneAdded(
        string description,
        uint256 deadline,
        uint256 paymentAmount
    );
    event MilestoneCompleted(uint256 milestoneIndex);
    event WorkAdded(uint256 milestoneIndex, string description);

    constructor() {
        _grantRole(ADMIN_ROLE, tx.origin);
    }

    // Add a new member
    function addMember(address _member) external onlyRole(ADMIN_ROLE) {
        _grantRole(MEMBER_ROLE, _member);
        members.add(_member);
        emit MemberAdded(_member);
    }

    // Remove a member
    function removeMember(address _member) external onlyRole(ADMIN_ROLE) {
        revokeRole(MEMBER_ROLE, _member);
        members.remove(_member);
        emit MemberRemoved(_member);
    }
    

    // Add project information
    
    function updateProject(
        string memory _name,
        string memory _description,
        string memory _url,
        uint256 _deadline
    ) external onlyRole(ADMIN_ROLE) {
        project.name = _name;
        project.description = _description;
        project.url = _url;
        project.deadline = _deadline;
        emit ProjectUpdated(_name, _description, _deadline, _url);
    }

    // Add a milestone
    function addMilestone(
        string memory _description,
        uint256 _deadline //added timestamp in seconds. 
    ) external onlyRole(ADMIN_ROLE) {
        Milestone memory newMilestone = Milestone({
            description: _description,
            deadline: block.timestamp + _deadline,
            completed: false,
            submitter: msg.sender,
            approvalVotes: 0
        });

        milestones.push(newMilestone);
        emit MilestoneAdded(_description, _deadline, 0);
    }

    // Mark a milestone as completed
    function completeMilestone(
        uint256 _milestoneIndex
    ) external onlyRole(MEMBER_ROLE) {
        require(
            !milestones[_milestoneIndex].completed,
            "Milestone already completed"
        );
        milestones[_milestoneIndex].completed = true;
        emit MilestoneCompleted(_milestoneIndex);

        // Logic to release payment can be added here
    }

    // WORKS
    // Add a new work to a milestone
    function addWork(
        uint256 _milestoneIndex,
        string memory _description
    ) external onlyRole(MEMBER_ROLE) {
        Work memory newWork = Work({
            milestoneIndex: _milestoneIndex,
            description: _description,
            assignee: msg.sender,
            status: WorkStatus.PENDING
        });

        works.push(newWork);
        emit WorkAdded(_milestoneIndex, _description);
    }


}
