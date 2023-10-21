// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract AchievementContract is
    ERC1155,
    Ownable,
    ERC1155Burnable,
    ERC1155Supply
{
    mapping(uint256 => bool) public lockedAchievements;
    mapping(uint256 => string) public _tokenCIDs;
    uint public totalAchievements;

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {
        string memory baseURI = "https://ipfs.io/ipfs/";
        string memory ownerAddress = string(abi.encodePacked(initialOwner));
        string memory fullURI = string(
            abi.encodePacked(baseURI, ownerAddress, "/")
        );
        _setURI(fullURI);
        totalAchievements = 0;        
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // we want to make sure that we use this in here.
    function addAchievement(
        string memory _details,
        bool locked
    ) public onlyOwner returns (uint256){
        uint256 achievementId = totalAchievements + 1;
        lockedAchievements[achievementId] = locked;
        _tokenCIDs[achievementId] = _details;
        totalAchievements = achievementId;
        

        //we want to add a mapping to see if an item is locked or not
        return achievementId;   
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.
    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory base = "https://ipfs.io/ipfs/";
        return string(abi.encodePacked(base, _tokenCIDs[tokenId]));
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    //TODO: write function to lock transfer before

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override onlyOwner {
        super.safeTransferFrom(from, to, id, amount, data);
    }
}
