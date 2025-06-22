// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable {
    uint public tokenCount;
    uint public listingFee = 0.01 ether;

    struct ListedItem {
        uint tokenId;
        address payable seller;
        uint price;
        bool isListed;
    }

    mapping(uint => ListedItem) public listedItems;

    constructor(address initialOwner) ERC721("MyNFT", "MNFT") Ownable(initialOwner) {}

    function mintNFT(string memory _tokenURI) public returns (uint) {
        tokenCount++;
        _mint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);
        return tokenCount;
    }

    function listNFT(uint _tokenId, uint _price) public payable {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner");
        require(_price > 0, "Price must be greater than zero");
        require(msg.value == listingFee, "Must pay listing fee");

        listedItems[_tokenId] = ListedItem(
            _tokenId,
            payable(msg.sender),
            _price,
            true
        );

        _transfer(msg.sender, address(this), _tokenId);
    }

    function buyNFT(uint _tokenId) public payable {
        ListedItem memory item = listedItems[_tokenId];
        require(item.isListed, "NFT is not for sale");
        require(msg.value == item.price, "Incorrect value");

        item.seller.transfer(msg.value);
        _transfer(address(this), msg.sender, _tokenId);

        listedItems[_tokenId].isListed = false;
    }

    function updateListingFee(uint _newFee) public onlyOwner {
        listingFee = _newFee;
    }
}
