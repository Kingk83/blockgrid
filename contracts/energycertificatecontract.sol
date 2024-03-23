// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev This contract implements an ERC721 token representing energy certificates.
 * Each token corresponds to a certain amount of energy (e.g., in kWh) that was produced
 * from a renewable source. It includes the ability to mint new tokens with associated
 * energy amounts and metadata URIs.
 */
contract EnergyCertificate is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId = 1;

    // Maps tokenId to the amount of energy (in kWh)
    mapping(uint256 => uint256) public certificateAmount;

    constructor() ERC721("RenewableEnergyCertificate", "REC") {}

    /**
     * @dev Mints a new energy certificate to the given address with the specified
     * amount of energy and metadata URI.
     * @param to Address to which the certificate will be minted
     * @param amount Amount of energy represented by the certificate
     * @param newTokenURI URI for the token metadata
     */
    function mintCertificate(address to, uint256 amount, string memory newTokenURI) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        certificateAmount[tokenId] = amount;
        _setTokenURI(tokenId, newTokenURI);
        // Emit an event or further logic here if needed
    }
    /**
     * @dev Sets the metadata URI for a given token.
     * @param tokenId The token ID for which to set the URI
     * @param newTokenURI The new URI to set
     */
    function _setTokenURI(uint256 tokenId, string memory newTokenURI) internal override {
        super._setTokenURI(tokenId, newTokenURI);
    }

    // Existing functions from ERC721 and ERC721URIStorage will handle
    // the rest of the token interactions (transfers, balance queries, etc.)

    // Additional functions can be added here for trading, retiring certificates,
    // or verifying ownership and amounts.
}