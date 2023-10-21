// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";


interface IPUSHCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}

contract ProjectContract is AccessControl, ERC721, IERC721Receiver {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Define roles
    address EPNS_FOR_MUMBAI = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");

    uint256 totalSupply = 0;
    // Project information
    struct Project {
        string name;
        string description;
        uint256 deadline; // timestamp for project completion
        string url; // URL to the project <- can be mumbai polyogn scanner
        address pushChannel;
    }
    
    struct NotificationSettings {
        bool onWorks;
        bool onRewards;
        bool onMember;
    }
    Project public project;
    NotificationSettings public notificationSettings;
    
    struct Works{
        string name;
        string url;
        bool active;
    }
    Works[] public works;

    // Members
    EnumerableSet.AddressSet private members;

    event MemberAdded(address member, uint256 tokenId);
    event MemberRemoved(address member);
    event ProjectUpdated(
        string name,
        string description,
        uint256 deadline,
        string url
    );
    event WorkAdded(string name, string url);
    event WorkRemoved(string name, string url);
    event NotificationUpdate(bool onWorks, bool onRewards, bool onMember);
    

    

    constructor(
        string memory _name,
        string memory _details
    ) ERC721(_name, "CZN") {
        project.description = _details;
        project.name = _name;
        _grantRole(ADMIN_ROLE, tx.origin);
        
        _safeMint(tx.origin, 1);
        totalSupply = 1;
    }

    function addMember(address _member) public onlyRole(ADMIN_ROLE) {
        totalSupply++;
        _safeMint(_member, totalSupply);
        _grantRole(MEMBER_ROLE, _member);

        members.add(_member);
        
        if (project.pushChannel != address(0) && notificationSettings.onMember) { 
            string memory notificationBody = string(
                abi.encodePacked(
                    "New member added:\n",
                    "Address: ",
                    Strings.toHexString(_member)
                )
            );
            
            notifyMembers("New Member Added", notificationBody);
        }
        emit MemberAdded(_member, totalSupply);
    }

    function makeAdmin(address _member) external onlyRole(ADMIN_ROLE) {
        _grantRole(ADMIN_ROLE, _member);
    }
    
    function updateSetting (
        bool _onWorks,
        bool _onRewards,
        bool _onMember
    ) external onlyRole(ADMIN_ROLE) {
        notificationSettings.onWorks = _onWorks;
        notificationSettings.onRewards = _onRewards;
        notificationSettings.onMember = _onMember;
        
        emit NotificationUpdate(_onWorks, _onRewards, _onMember);
    }
    
    // Remove a member
    function removeMember(address _member, uint256 tokenId) external onlyRole(ADMIN_ROLE) {
        revokeRole(MEMBER_ROLE, _member);
        members.remove(_member);
        _burn(tokenId);
        emit MemberRemoved(_member);
        
        if (project.pushChannel != address(0) && notificationSettings.onMember) { 
            string memory notificationBody = string(
                abi.encodePacked(
                    "Member removed:\n",
                    "Address: ",
                    Strings.toHexString(_member)
                )
            );
            
            notifyMembers("Member Removed", notificationBody);
        }
    }
    
    function addWork(string memory _name, string memory _url) external onlyRole(MEMBER_ROLE) {
        works.push(Works(_name, _url, true));
        emit WorkAdded(_name, _url);
        if (project.pushChannel != address(0) && notificationSettings.onWorks) { 
            string memory notificationBody = string(
                abi.encodePacked(
                    "New work added:\n",
                    "Name: ",
                    _name,
                    "\nURL: ",
                    _url
                )
            );
            
            notifyMembers("New Work Added", notificationBody);
        }
        
        
        
        
    }
    
    function removeWork(uint256 _index) external onlyRole(MEMBER_ROLE) {
        works[_index].active = false;
        
        emit WorkRemoved(works[_index].name, works[_index].url);
        if (project.pushChannel != address(0) && notificationSettings.onWorks) { 
            string memory notificationBody = string(
                abi.encodePacked(
                    "Work removed:\n",
                    "Name: ",
                    works[_index].name,
                    "\nURL: ",
                    works[_index].url
                )
            );
            
            notifyMembers("Work Removed", notificationBody);
        }
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

    //base uri
    function uri(uint256 tokenId) public view  returns (string memory) {
        string memory base = "https://ipfs.io/ipfs/";
        return string(abi.encodePacked(base));
    }

    function updatePushChannel(
        address _pushChannel, 
        bool _onWorks,
        bool _onRewards,
        bool _onMember
    ) external onlyRole(ADMIN_ROLE) {
        project.pushChannel = _pushChannel;
        notificationSettings.onWorks = _onWorks;
        notificationSettings.onRewards = _onRewards;
        notificationSettings.onMember = _onMember;
        
        if (project.pushChannel != address(0)) { 
            string memory notificationBody = string(
                abi.encodePacked(
                    "Setup succesfullly created from the contract! \n", 
                    Strings.toHexString(_pushChannel)
                )
            );
            
            notifyMembers("New Push Channel Set", notificationBody);
        }
    }

    //handle received tokens here..
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // Handle the received token here
        if (project.pushChannel != address(0) && notificationSettings.onRewards) { 
            string memory notificationBody = string(
                abi.encodePacked(
                    "You received the following NFT:\n",
                    "Token ID: ",
                    Strings.toString(tokenId),
                    "\nFrom: ",
                    Strings.toHexString(from),  
                    "\nOperator: ",
                    Strings.toHexString(operator), 
                    "\nToken URI: ",
                    tokenURI(tokenId)  
                )
            );
            
            notifyMembers("New NFT Received", notificationBody);
        }

        return this.onERC721Received.selector;
    }
    
    function notifyMembers(string memory _title, string memory _body) internal {
            IPUSHCommInterface(EPNS_FOR_MUMBAI).sendNotification(
                project.pushChannel,
                address(this),
                bytes(
                    string(
                        // We are passing identity here: https://push.org/docs/notifications/notification-standards/notification-standards-advance/#notification-identity
                        abi.encodePacked(
                            "0", // this represents minimal identity, learn more: https://push.org/docs/notifications/notification-standards/notification-standards-advance/#notification-identity
                            "+", // segregator
                            "1", // define notification type:  https://push.org/docs/notifications/build/types-of-notification (1, 3 or 4) = (Broadcast, targetted or subset)
                            "+", // segregator
                            _title, // this is notificaiton title
                            "+", // segregator
                            _body // this is notificaiton body
                        )
                    )
                )
            );

    }
    
    
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
