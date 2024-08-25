pragma solidity ^0.4.25;

contract Warehouse {
    // inventory struct 
    struct Inventory {
        uint[] itemIds; //this and stock are = in length
        uint[] stock;
        uint cost; // Cost in Gwei
        address owner;
    }

    // events
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId, string metadata);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event Purchase(string metadata);
    event RandomNumberGenerated(uint indexed randomNumber);
    event ListingCreated(uint indexed listingId, address indexed owner);

    // erc721 stuff
    mapping(uint256 => address) internal tokenOwner;
    mapping(uint256 => address) internal tokenApprovals;
    mapping(address => uint256[]) internal ownedTokens;
    mapping(uint256 => string) internal tokenMetadata;
    string public name;
    string public symbol;
    uint256 public totalTokens;

    // mapping listing ids to inventory structs
    mapping(uint => Inventory) public inventoryById;
    uint[] public allListings;

    // constructor for erc721 token
    constructor(string _name, string _symbol) public {
        name = _name;
        symbol = _symbol;
    }

    // erc721 functions
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownedTokens[_owner].length;
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        require(tokenOwner[_tokenId] != address(0), "Token does not exist");
        return tokenOwner[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(msg.sender == _from || msg.sender == tokenApprovals[_tokenId], "Not authorized to transfer");
        require(tokenOwner[_tokenId] == _from, "Token does not belong to the sender");

        tokenOwner[_tokenId] = _to;
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        string memory metadata = generateMetadata(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId, metadata);
    }

    function approve(address _approved, uint256 _tokenId) public {
        require(tokenOwner[_tokenId] == msg.sender, "Not authorized to approve");

        tokenApprovals[_tokenId] = _approved;

        emit Approval(tokenOwner[_tokenId], _approved, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public {
        require(tokenApprovals[_tokenId] == msg.sender, "Not approved to take ownership");
        address _from = tokenOwner[_tokenId];
        address _to = msg.sender;

        tokenOwner[_tokenId] = _to;
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        string memory metadata = generateMetadata(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId, metadata);
    }

    function totalSupply() public view returns (uint256) {
        return totalTokens;
    }

    function getName() public view returns (string) {
        return name;
    }

    function getSymbol() public view returns (string) {
        return symbol;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < ownedTokens[_owner].length, "Index out of bounds");
        return ownedTokens[_owner][_index];
    }

    // this function is more modified, we add our metadata at mint time
    function mint(address _to, uint256 _listingId, uint256 _itemId) internal returns (uint256, string memory) {
        uint tokenId = uint(keccak256(abi.encodePacked(_listingId, uint256(0), _itemId, uint256(0), block.timestamp)));

        require(tokenOwner[tokenId] == address(0), "Token already exists");

        tokenOwner[tokenId] = _to;
        addTokenTo(_to, tokenId);
        totalTokens++;

        string memory metadata = generateMetadata(_to, _itemId, _listingId, block.timestamp, tokenId);
        tokenMetadata[tokenId] = metadata;

        emit Transfer(address(0), _to, tokenId, metadata);

    return (tokenId, metadata);
}

    function addTokenTo(address _to, uint256 _tokenId) internal {
        ownedTokens[_to].push(_tokenId);
    }

    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        uint256[] storage tokenArray = ownedTokens[_from];
        for (uint256 i = 0; i < tokenArray.length; i++) {
            if (tokenArray[i] == _tokenId) {
                if (i != tokenArray.length - 1) {
                    tokenArray[i] = tokenArray[tokenArray.length - 1];
                }
                tokenArray.length--;
                return;
            }
        }
    }

    // function to create an inventory with a listing id
    function setInventoryData(uint _listingId, uint[] memory _itemIds, uint[] memory _stock, uint _costInGwei) public {
        require(_itemIds.length == _stock.length, "Arrays must have the same length");
        require(_itemIds.length > 0, "Empty inventory not allowed");

        // cost to gwei
        uint _costInWei = _costInGwei * 1e9;

        // new inventory
        Inventory memory newInventory = Inventory({
            itemIds: _itemIds,
            stock: _stock,
            cost: _costInWei,
            owner: msg.sender
        });
        inventoryById[_listingId] = newInventory;
        allListings.push(_listingId);

        emit ListingCreated(_listingId, msg.sender);
    }

    // function to buy item from listing
    function buyItems(uint _listingId) public payable returns (string memory metadata) {
        Inventory storage inventory = inventoryById[_listingId];

        // checking balance and if listing exists
        require(msg.value >= inventory.cost, "Insufficient funds");
        require(inventory.itemIds.length > 0 && inventory.stock.length > 0, "Listing not found");

        // clearing empty listings if they exist
        uint[] memory newStock = new uint[](inventory.stock.length);
        uint[] memory newItemIds = new uint[](inventory.itemIds.length);
        uint itemCount = 0;
        for (uint i = 0; i < inventory.stock.length; i++) {
            if (inventory.stock[i] > 0) {
                newStock[itemCount] = inventory.stock[i];
                newItemIds[itemCount] = inventory.itemIds[i];
                itemCount++;
            }
        }
        require(itemCount > 0, "All items out of stock");

        // psuedo random number selection
        uint randomNumber = generateRandomNumber(_listingId, itemCount);

        uint itemIndex = uint(randomNumber);

        // should always pass but just incase
        require(newStock[itemIndex] > 0, "Item out of stock");

        // update the stock
        if (newStock[itemIndex] == 1) {
            // if stock will become 0 after purchase
            delete newStock[itemIndex];
            delete newItemIds[itemIndex];
        } else {
            newStock[itemIndex]--;
        }

        // update inventory
        inventory.stock = newStock;
        inventory.itemIds = newItemIds;

        // mint
        uint selectedItemId = newItemIds[itemIndex];
        uint tokenId;
        (tokenId, metadata) = mint(msg.sender, _listingId, selectedItemId);

        // purchase event
        emit Purchase(metadata);

        // delete empty listing if exists
        bool allItemsSoldOut = true;
        for (uint j = 0; j < newStock.length; j++) {
            if (newStock[j] > 0) {
                allItemsSoldOut = false;
                break;
            }
        }
        if (allItemsSoldOut) {
            delete inventoryById[_listingId];
            for (uint k = 0; k < allListings.length; k++) {
                if (allListings[k] == _listingId) {
                    if (k != allListings.length - 1) {
                        allListings[k] = allListings[allListings.length - 1];
                    }
                    allListings.length--;
                    break;
                }
            }
        }

        return metadata;
    }

    // generate a psuedo random number
    function generateRandomNumber(uint _listingId, uint maxValue) internal view returns (uint) {
        uint randomNumber = uint(keccak256(abi.encodePacked(_listingId, now, msg.sender))) % maxValue;
        emit RandomNumberGenerated(randomNumber);
        return randomNumber;
    }

    // helper to convert uint to string
    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory b = new bytes(len);
        uint k = len - 1;
        while (v != 0) {
            b[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }
        return string(b);
    }

    // our metadata generator
    function generateMetadata(address _buyer, uint _itemId, uint _listingId, uint _timestamp, uint256 _tokenId) internal pure returns (string memory) {
        string memory buyerAddr = toAsciiString(abi.encodePacked(_buyer));
        string memory itemIdStr = uintToString(_itemId);
        string memory listingIdStr = uintToString(_listingId);
        string memory dateTimeStr = timestampToDate(_timestamp);
        string memory tokenIdStr = uintToString(_tokenId);
        string memory metadata = string(abi.encodePacked(buyerAddr, " recieved token ", tokenIdStr, " and won itemID ", itemIdStr, " from listing ", listingIdStr, " on ", dateTimeStr));
        return metadata;
    }

    function timestampToDate(uint _timestamp) internal pure returns (string memory) {
    uint year = _timestamp / 31536000 + 1970;
    uint month = (_timestamp % 31536000) / 2629800;
    uint day = ((_timestamp % 31536000) % 2629800) / 86400;
    uint hour = ((_timestamp % 31536000) % 2629800) % 86400 / 3600;
    uint minute = (((_timestamp % 31536000) % 2629800) % 86400 % 3600) / 60;
    uint second = ((_timestamp % 31536000) % 2629800) % 86400 % 3600 % 60;

    return string(abi.encodePacked(uintToString(year), "-", uintToString(month + 1), "-", uintToString(day + 1), " ", uintToString(hour), ":", uintToString(minute), ":", uintToString(second)));
}

    // metadata for transfers
    function generateMetadata(address _newOwner, uint256 _tokenId) internal view returns (string memory) {
        string memory newOwnerAddr = toAsciiString(abi.encodePacked(_newOwner));
        string memory tokenIdStr = uintToString(_tokenId);
        string memory metadata = string(abi.encodePacked(newOwnerAddr, " received token ", tokenIdStr));
        return metadata;
    }

    // view function to get cost, stock, item IDs, and owner of a listing
    function viewInventoryById(uint _listingId) public view returns (uint, uint[] memory, uint[] memory, address) {
        Inventory memory listing = inventoryById[_listingId];
        if (listing.owner == address(0)) {
            // no listing found
            return (0, new uint[](0), new uint[](0), address(0));
        }
        return (listing.cost, listing.stock, listing.itemIds, listing.owner);
    }

    // get IDs of all current valid listings
    function viewAllListings() public view returns (uint[] memory) {
        uint[] memory listingsData = new uint[](allListings.length * 2);

        for (uint i = 0; i < allListings.length; i++) {
            uint listingId = allListings[i];
            Inventory memory listing = inventoryById[listingId];
            uint index = i * 2;

            // set listing ID and cost in the array
            listingsData[index] = listingId;
            listingsData[index + 1] = listing.cost;
        }

        return listingsData;
    }

    // get metadata of token
    function getTokenMetadata(uint256 _tokenId) public view returns (string memory) {
        return tokenMetadata[_tokenId];
    }

    // get tokens owned by owner
    function tokensOfOwner(address _owner) public view returns (uint256[] memory) {
        return ownedTokens[_owner];
    }


    // helper to convert address to ASCII string
    function toAsciiString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    //return list of all token's metadata from an owner
    function getAllMetadata(address _owner) public view returns (string memory) {
        uint256[] memory allTokens = tokensOfOwner(_owner);
        string memory allMetadata;

        for (uint i = 0; i < allTokens.length; i++) {
            uint256 tokenId = allTokens[i];

            string memory metadata = getTokenMetadata(tokenId);

            allMetadata = string(abi.encodePacked(allMetadata, metadata, "<d>"));
        }

        return allMetadata;
    }
}