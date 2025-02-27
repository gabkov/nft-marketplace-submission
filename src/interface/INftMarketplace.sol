// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface INftMarketPlace {
    // Errors
    error NotTokenOwner();
    error TokenNotApprovedForListing();
    error ListingAlreadyExists(address tokenAddress, uint256 tokenId);
    error ListingNotFound(address tokenAddress, uint256 tokenId);
    error InsufficientPayment(uint256 required, uint256 provided);
    error TransferFailed();
    error ZeroPrice();
    error NoProceeds(address seller);

    // Events
    event ItemListed(address indexed tokenAddress, uint256 indexed tokenId, address indexed seller, uint256 price);
    event ListingCancelled(address indexed tokenAddress, uint256 indexed tokenId);
    event ItemBought(address indexed tokenAddress, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event ListingUpdated(address indexed tokenAddress, uint256 indexed tokenId, uint256 oldPrice, uint256 newPrice);
    event ProceedsWithdrawn(address indexed seller, uint256 amount);

    // Structs
    struct Listing {
        address seller;
        uint256 price;
    }

    // Functions

    /// @notice Returns the listing for a given token address and token ID.
    /// @param tokenAddress The address of the token contract.
    /// @param tokenId The ID of the token.
    /// @return The listing details, including the seller and price.
    function listings(address tokenAddress, uint256 tokenId) external view returns (Listing memory);

    /// @notice Returns the proceeds available for a given seller.
    /// @param seller The address of the seller.
    /// @return The amount of proceeds available for withdrawal.
    function proceeds(address seller) external view returns (uint256);

    /// @notice Lists an NFT for sale.
    /// @param tokenAddress The address of the token contract.
    /// @param tokenId The ID of the token.
    /// @param price The price at which the token is listed.
    /// @dev The caller must be the owner of the token and must have approved the marketplace to transfer the token.
    function listItem(address tokenAddress, uint256 tokenId, uint256 price) external;

    /// @notice Cancels an existing listing.
    /// @param tokenAddress The address of the token contract.
    /// @param tokenId The ID of the token.
    /// @dev The caller must be the seller of the token.
    function cancelListing(address tokenAddress, uint256 tokenId) external;

    /// @notice Purchases a listed NFT.
    /// @param tokenAddress The address of the token contract.
    /// @param tokenId The ID of the token.
    /// @dev The caller must send the required payment in ETH.
    function buyItem(address tokenAddress, uint256 tokenId) external payable;

    /// @notice Updates the price of an existing listing.
    /// @param tokenAddress The address of the token contract.
    /// @param tokenId The ID of the token.
    /// @param newPrice The new price of the token.
    /// @dev The caller must be the seller of the token.
    function updateListing(address tokenAddress, uint256 tokenId, uint256 newPrice) external;

    /// @notice Withdraws proceeds from sales.
    /// @dev The caller must have proceeds available to withdraw.
    function withdrawProceeds() external;
}
