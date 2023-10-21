// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "./AchievementContract.sol";


interface IERC6551Registry {
    event AccountCreated(
        address account,
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    );

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 seed,
        bytes calldata initData
    ) external returns (address);

    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address);
}
contract GroupToken is ERC721, ERC721URIStorage, AccessControl, ERC721Burnable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IERC6551Registry public ERC6551Registry;
    address public ERC6551AccountImplementation;
    string public details;

    uint public totalSupply;

    AchievementContract public achievementContract;

    event AchievementAdded(
        uint256 indexed achievementId,
        string description,
        bool locked
    );
    event MemberCreated(
        address member,
        uint256 tokenId,
        address tokenboundAccount
    );
    event GroupUpdated(string name, string image, string details);
    event AchievementContractCreated(
        address achievementContract,
        uint creationTime
    );
    event AchievementRewarded(
        address member,
        uint256 achievementId,
        uint256 amount
    );
    event AchievementBatchRewarded(
        address member,
        uint256[] achievementIds,
        uint256[] amounts
    );

    event MemberDeleted(address indexed member, uint256 tokenId);
    event NewRoleAdded(
        string roleName,
        bytes32 indexed newRole,
        address indexed admin
    );

    constructor(
        address _ERC6551Registry,
        address _ERC6551AccountImplementation,
        string memory name,
        string memory _details
    ) ERC721(name, "CZN") {
        ERC6551Registry = IERC6551Registry(_ERC6551Registry);
        ERC6551AccountImplementation = _ERC6551AccountImplementation;
        _grantRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _grantRole(MINTER_ROLE, tx.origin);
        details = _details;
        AchievementContract addedAchievementContract = new AchievementContract(
            address(this)
        );
        achievementContract = addedAchievementContract;
        totalSupply = 0;

        emit AchievementContractCreated(
            address(addedAchievementContract),
            block.timestamp
        );
    }

    //automatically add the user with this
    function createMember(address to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        //get the token id
        uint256 tokenId = totalSupply + 1;
        _safeMint(to, tokenId);
        require(
            tokenBoundCreation(tokenId),
            "Tokenbound account creation failed"
        );
        address tokenbounded = getTBA(tokenId);

        totalSupply = totalSupply + 1;
        emit MemberCreated(to, tokenId, tokenbounded);
    }

    function updateDetails(
        string memory _details
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        details = _details;

        emit GroupUpdated(name(), symbol(), details);
    }

    function addAchievement(
        string memory _description,
        bool _locked
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint tokenId = achievementContract.addAchievement(
            _description,
            _locked
        );

        emit AchievementAdded(tokenId, _description, _locked);
    }

    function distributeAchievement(
        uint256 _achievementId,
        address _to,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        achievementContract.mint(_to, _achievementId, _amount, "");
        emit AchievementRewarded(_to, _achievementId, _amount);
    }
    
    function rewardProject(
        uint256 _achievementId,
        address[] memory _to
    ) public onlyRole(DEFAULT_ADMIN_ROLE){

        for(uint i = 0; i < _to.length; i++){
            achievementContract.mint(_to[i], _achievementId, 1, "");
            emit AchievementRewarded(_to[i], _achievementId, 1);
        }
    }


    function batchDistibuteAchievements(
        uint256[] memory _achievementIds,
        address _to,
        uint256[] memory _amounts
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        achievementContract.mintBatch(_to, _achievementIds, _amounts, "");
        emit AchievementBatchRewarded(_to, _achievementIds, _amounts);
    }

    //check if the tokenbound account is created

    function tokenBoundCreation(uint256 tokenId) internal returns (bool) {
        ERC6551Registry.createAccount(
            ERC6551AccountImplementation,
            block.chainid,
            address(this),
            tokenId,
            0,
            abi.encodeWithSignature("initialize()", msg.sender)
        );
        return true;
    }
 
    function getTBA(uint256 _tokenId) public view returns (address) {
        return
            ERC6551Registry.account(
                ERC6551AccountImplementation,
                block.chainid,
                address(this),
                _tokenId,
                0
            );
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721) returns (address) {
        return super._update(to, tokenId, auth);
    }

    // Function to grant a new role to a member
    function grantMemberRole(
        address member,
        bytes32 role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(role, member);
        emit RoleGranted(role, member, msg.sender);
    }

    // Function to revoke a role from a member
    function revokeMemberRole(
        address member,
        bytes32 role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(role, member);
    }

    // Function to delete a member
    function deleteMember(uint256 tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {

        require(tokenId != 0, "Token does not exist");
        require(tokenId <= totalSupply, "Token does not exist");

        address member = ownerOf(tokenId);

        // Burning the member's NFT
        _burn(tokenId);
        emit MemberDeleted(member, tokenId);
    }

    // Function to add a new role
    function addNewRole(
        string memory newRole
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(bytes32(keccak256(abi.encodePacked(newRole))), msg.sender); // Assigning the new role to the admin

        emit NewRoleAdded(
            newRole,
            bytes32(keccak256(abi.encodePacked(newRole))),
            msg.sender
        );
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
