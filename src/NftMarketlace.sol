// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {INFTMarketplace} from "./interface/INftMarketPlace.sol";

contract NFTMarketplace is INFTMarketplace, ReentrancyGuardTransient {
    mapping(address => mapping(uint256 => Listing)) internal _listings;

    /// @inheritdoc INFTMarketplace
    mapping(address => uint256) public proceeds;

    modifier isOwner(address tokenAddress, uint256 tokenId, address spender) {
        if (spender != IERC721(tokenAddress).ownerOf(tokenId)) {
            revert NotTokenOwner();
        }
        _;
    }

    modifier isListed(address tokenAddress, uint256 tokenId) {
        if (_listings[tokenAddress][tokenId].price == 0) {
            revert ListingNotFound(tokenAddress, tokenId);
        }
        _;
    }

    /// @inheritdoc INFTMarketplace
    function listings(address tokenAddress, uint256 tokenId) external view returns (Listing memory) {
        return _listings[tokenAddress][tokenId];
    }

    /// @inheritdoc INFTMarketplace
    function listItem(address tokenAddress, uint256 tokenId, uint256 price)
        external
        isOwner(tokenAddress, tokenId, msg.sender)
    {
        if (_listings[tokenAddress][tokenId].price != 0) {
            revert ListingAlreadyExists(tokenAddress, tokenId);
        }

        if (IERC721(tokenAddress).getApproved(tokenId) != address(this)) {
            revert TokenNotApprovedForListing();
        }

        _listings[tokenAddress][tokenId] = Listing({seller: msg.sender, price: price});

        emit ItemListed(tokenAddress, tokenId, msg.sender, price);
    }

    /// @inheritdoc INFTMarketplace
    function cancelListing(address tokenAddress, uint256 tokenId)
        external
        isOwner(tokenAddress, tokenId, msg.sender)
        isListed(tokenAddress, tokenId)
    {
        delete _listings[tokenAddress][tokenId];
        emit ListingCancelled(tokenAddress, tokenId);
    }

    /// @inheritdoc INFTMarketplace
    function buyItem(address tokenAddress, uint256 tokenId)
        external
        payable
        nonReentrant
        isListed(tokenAddress, tokenId)
    {
        Listing memory listing = _listings[tokenAddress][tokenId];

        if (msg.value < listing.price) revert InsufficientPayment(listing.price, msg.value);

        delete _listings[tokenAddress][tokenId];

        IERC721(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId);

        proceeds[listing.seller] += msg.value;

        emit ItemBought(tokenAddress, tokenId, msg.sender, listing.price);
    }

    /// @inheritdoc INFTMarketplace
    function updateListing(address tokenAddress, uint256 tokenId, uint256 newPrice)
        external
        isOwner(tokenAddress, tokenId, msg.sender)
        isListed(tokenAddress, tokenId)
    {
        if (newPrice <= 0) revert ZeroPrice();
        _listings[tokenAddress][tokenId].price = newPrice;

        emit ListingUpdated(tokenAddress, tokenId, newPrice);
    }

    /// @inheritdoc INFTMarketplace
    function withdrawProceeds() external nonReentrant {
        uint256 amount = proceeds[msg.sender];

        if (amount == 0) revert NoProceeds(msg.sender);

        proceeds[msg.sender] = 0;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }

        emit ProceedsWithdrawn(msg.sender, amount);
    }

    receive() external payable {}
    fallback() external payable {}
}
