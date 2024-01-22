//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./libraries/rarible/impl/RoyaltiesV2Impl.sol";
import "./libraries/rarible/LibPart.sol";
import "./libraries/rarible/LibRoyaltiesV2.sol";

contract ERC721Royalties is ERC721Enumerable, Ownable, RoyaltiesV2Impl {
    using Strings for uint256;

    string baseURI;
    string public baseExtension = "";

    uint256 public cost = 0.005 ether;

    uint256 public maxSupply = 100;

    uint256 public maxMintAmount = 1;

    bool public paused = false;

    bool public revealed = true;

    string public notRevealedUri;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    uint96 public RoyaltiesPercentageBasisPoints = 1000;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setNotRevealedURI(
        string memory _newNotRevealedURI
    ) public onlyOwner {
        notRevealedUri = _newNotRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setMaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner {
        maxMintAmount = _newMaxMintAmount;
    }

    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        maxSupply = _newMaxSupply;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function reveal(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setRoyalties(
        uint256 _tokenId,
        address payable _royaltiesRecipientAddress,
        uint96 _percentageBasisPoint
    ) public onlyOwner {
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = _percentageBasisPoint;
        _royalties[0].account = _royaltiesRecipientAddress;
        _saveRoyalties(_tokenId, _royalties);
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");

        if (revealed == false) {
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI();

        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokensIds = new uint256[](ownerTokenCount);
        for (uint256 i = 0; i < ownerTokenCount; i++) {
            tokensIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensIds;
    }

    function mint(uint256 _mintAmount) public payable {
        uint supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount);
        }

        address payable own = payable(owner());

        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newId = supply + i;
            _safeMint(msg.sender, newId);
            LibPart.Part[] memory _royalties = new LibPart.Part[](1);
            _royalties[0].value = RoyaltiesPercentageBasisPoints;
            _royalties[0].account = own;
            _saveRoyalties(newId, _royalties);
        }
        own.transfer(msg.value);
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address payable receiver, uint256 royaltyAmount) {
        LibPart.Part[] memory _royalties = royalties[_tokenId];
        if (_royalties.length > 0) {
            return (
                _royalties[0].account,
                (_salePrice * _royalties[0].value) / 10000
            );
        }
        return (payable(address(0)), 0);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Enumerable) returns (bool) {
        if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }

        if (interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
        }

        return super.supportsInterface(interfaceId);
    }
}
