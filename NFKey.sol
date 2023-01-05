// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFKey {
    /*
    Product Flow
    - Creator generates a random private key called NFKey off-chain
    - Creator gets Item Id from NFTKey by calling nfKeyToItemId() off-chain
    - Creator calls create(itemId) to prove this item is authentic aka "I created this. Here's proof on chain"
    - Creator attaches NFKey to NFC and attaches to swag
    - Buyer buys swag that has NFKey
    - Buyer gets Auth Key from NFTKey by calling nfKeyToAuthKey() off-chain
    - Auth Key is used to authenticate the purchase aka "I bought this"
    - Buyer authenticates by submitting Auth Key on-chain aka "Item #4 was auth on Jan 1"

    How to prove authenticity
    - If the buyer duplicates the NFC and sells fake swag
    - The scammed buyer will try and authenticate
    - On authenticate, they will recieve a message "Item already authenticated"
    */

    // stores info about item
    struct ItemId { 
        address creator;
        bool isAuthenticated;
    }

    // maps authKey => ItemId
    mapping (bytes32 => ItemId) public itemIds;

    // events
    event Create(bytes32 _itemId, address _creator);
    event Authenticate(bytes32 _itemId, bool _isAuthenticated);

    // anyone can create an item
    function create(bytes32 _itemId) public {
        require(itemIds[_itemId].creator == address(0x0), "Item already created");
        itemIds[_itemId].creator = msg.sender;
        emit Create(_itemId, msg.sender);
    }

    // purchaser can authenticate
    function authenticate(bytes32 _authKey) public {
        bytes32 itemId = authKeyToItemId(_authKey);
        require(itemIds[itemId].isAuthenticated == false, "Item already authenticated");
        itemIds[itemId].isAuthenticated = true;
        emit Authenticate(itemId, true);
    }

    /*
    * Hashing functions
    * nfKey -> authKey -> itemId
    * nfKey     -- nfKeyToAuthKey() --> authKey
    * authKey   -- authKeyToItemId()--> itemId
    * nfKey     -- nfKeyToItemId()  --> itemId
    */
    // hashes nfKey to authKey
    function nfKeyToAuthKey(string memory _nfKey) public pure returns (bytes32) {
        bytes32 authKey = sha256(abi.encodePacked(_nfKey));
        return authKey;
    }
    // hashes authKey to ItemId
    function authKeyToItemId(bytes32 _authKey) public pure returns(bytes32){
        bytes32 itemId = sha256(abi.encodePacked(_authKey));
        return itemId;
    }
    // hashes nfKey to itemId
    function nfKeyToItemId(string memory _nfKey) public pure returns(bytes32){
        bytes32 authKey = sha256(abi.encodePacked(_nfKey));
        bytes32 itemId = sha256(abi.encodePacked(authKey));
        return itemId;
    }

}
