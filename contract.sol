pragma solidity ^0.8.0;

import "https://github.com/ethereum-bridge/ethereum-bridge-contracts/Bridge.sol";

contract MultiChainNFTWallet {
    // Mapping to store NFTs
    mapping(bytes32 => bool) public nfts;

    // Event for NFT transfer
    event Transfer(address indexed _from, bytes32 _tokenId, bytes memory _data, address _toChain);

    // Bridge contract instance
    Bridge public bridge;

    // Security measure to prevent unauthorized contract calls
    address public owner;

    constructor(address _bridge) public {
        require(_bridge != address(0));
        owner = msg.sender;
        bridge = Bridge(_bridge);
    }

    // Function to add an NFT to the wallet
    function addNFT(bytes32 _tokenId) public {
        require(msg.sender == owner);
        require(nfts[_tokenId] == false);
        nfts[_tokenId] = true;
    }

    // Function to remove an NFT from the wallet
    function removeNFT(bytes32 _tokenId) public {
        require(msg.sender == owner);
        require(nfts[_tokenId] == true);
        nfts[_tokenId] = false;
    }

    // Function to transfer an NFT to another blockchain
    function transferNFT(bytes32 _tokenId, bytes memory _data, address _toChain) public {
        require(msg.sender == owner);
        require(nfts[_tokenId] == true);
        require(_toChain != address(0));

        // Send the NFT to the other blockchain
        (bool success, bytes memory returnData) = bridge.transfer(_tokenId, _data, address(this), _toChain);

        // Check for errors
        require(success, "Error: Transfer failed");
        emit Transfer(msg.sender, _tokenId, _data, _toChain);
    }

    // Function to change the owner address
    function changeOwner(address newOwner) public {
        require(msg.sender == owner);
        require(newOwner != address(0));
        owner = newOwner;
    }
}
