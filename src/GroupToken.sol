// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Votes.sol";

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

contract GroupToken is ERC721, ERC721URIStorage, ERC721Pausable, AccessControl, ERC721Burnable, EIP712, ERC721Votes {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    //TokenboundAccount implementation
    IERC6551Registry public ERC6551Registry;
    address public ERC6551AccountImplementation;
    string public details;
    
    AchievementContract public achievementContract;
 
    constructor(address _ERC6551Registry, address _ERC6551AccountImplementation, string memory name, string memory symbol, string memory _details)
        ERC721(name, symbol)
        EIP712(name, "1")
    {
     
        ERC6551Registry = IERC6551Registry(_ERC6551Registry);
        ERC6551AccountImplementation = _ERC6551AccountImplementation;
        _grantRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _grantRole(PAUSER_ROLE, tx.origin);
        _grantRole(MINTER_ROLE, tx.origin);
        details = _details;
        AchievementContract addedAchievementContract = new AchievementContract(address(this));
        achievementContract = addedAchievementContract;
        
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }
    

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId, string memory uri)
        public
        onlyRole(MINTER_ROLE)
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
    
    function updateDetails(string memory _details) public onlyRole(DEFAULT_ADMIN_ROLE) {
        details = _details;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable, ERC721Votes)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Votes)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    //We want all the achievement functionalities to work here 

}