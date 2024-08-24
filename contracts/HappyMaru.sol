// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract HappyMaru is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    Counters.Counter private userIds;

    struct dogInfo {
        uint256 tokenId;
        address payable owner;
        // 이름
        string name;
        // 견종
        string breed;
        // 생일
        string birthDate;
        // 성별 
        string gender;
        // 중성화 여부
        bool neutraled;
        // 소개글
        string description;
        // 사진
        string image;
    }

    mapping(uint256 => dogInfo) private nfts;
    mapping(address => uint256[]) private dogOwners;
    mapping(uint256 => string) private tokenURIs;

    event DogInfoCreated(
        uint256 indexed tokenId,
        address payable owner,
        string name,
        string breed,
        string birthDate,
        string gender,
        bool neutraled,
        string description,
        string image
    );

    constructor() ERC721("Happy Maru", "HappyMaru's dog INFO ") {
        tokenIds.increment();
        userIds.increment();
    }

    function setNft(
        uint256 _tokenId,
        dogInfo memory _info,
        string memory tokenURI
    ) private {
        nfts[_tokenId] = _info;
        tokenURIs[_tokenId] = tokenURI;
        emit DogInfoCreated(
            _tokenId,
            payable(msg.sender),
            _info.name,
            _info.breed,
            _info.birthDate,
            _info.gender,
            _info.neutraled,
            _info.description,
            _info.image
        );
    }

    /// @dev this function mints received NFTs
    /// @param _name name
    /// @param _breed breed
    /// @param _birthDate birthDate
    /// @param _gender gender
    /// @param _neutraled neutraled
    /// @param _description description
    /// @param _image image Url
    /// @param _tokenURI image Url
    /// @return newTokenId of the created NFT
    function createDogInfo(
        string memory _name,
        string memory _breed,
        string memory _birthDate,
        string memory _gender,
        bool _neutraled,
        string memory _description,
        string memory _image,
        string memory _tokenURI,
        address payable _address
    ) public returns (uint256) {
        uint256 newTokenId = tokenIds.current();
        _mint(_address, newTokenId);

        _setTokenURI(newTokenId, _tokenURI);
        dogOwners[_address].push(newTokenId);
        dogInfo memory _info = dogInfo(newTokenId, payable(_address), _name, _breed, _birthDate, _gender, _neutraled, _description, _image);
        setNft(
            newTokenId, _info, _tokenURI
        );
        tokenIds.increment();
        return newTokenId;
    }


    /// @dev fetches NFT that a specific user has created
    /// @return nftStruct[] list of nfts created by a user with their metadata
    function getNfts() public view returns (dogInfo[] memory) {
        uint256 nftCount = tokenIds.current();
        dogInfo[] memory myNfts = new dogInfo[](nftCount);
        uint256 j = 0;
        for (uint256 i = 1; i < nftCount; i++) {
            if (ownerOf(i) == msg.sender) {
                myNfts[j] = nfts[i];
                j++;
            }
        }
        dogInfo[] memory returnMyNFts = new dogInfo[](j);
        for (uint256 i = 0; i < j; i++) {
            returnMyNFts[i] = myNfts[i];
        }
        return returnMyNFts;
    }

    /// @dev fetches details of a particular
    /// @param _tokenId The token ID
    /// @return nftStruct NFT data of the specific token ID
    function getIndividualNFT(
        uint256 _tokenId
    ) public view returns (dogInfo memory) {
        return nfts[_tokenId];
    }

    function getNftsByAddress(address owner) public view returns (uint256[] memory) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return dogOwners[owner];
    }

    function sendNft(address from, address payable to, uint256 tokenId) public returns (uint256) {
        safeTransferFrom(from, to, tokenId);
        // owner 소유자 변경
        nfts[tokenId].owner = to;
        return tokenId;
    }

    function getNftsCount() public view returns (uint256) {
        return tokenIds.current();
    }

    /// @dev this function mints received NFTs
    /// @param _tokenURI the new token URI
    /// @param _info dogInfo
    /// @return newTokenId
    function createAndSendNft(
        string memory _tokenURI,
        dogInfo memory _info,
        address from, address payable to
    ) public returns (uint256) {
        uint256 newTokenId = tokenIds.current();
        _mint(from, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        dogOwners[from].push(newTokenId);
        setNft(
            newTokenId, _info, _tokenURI
        );
        tokenIds.increment();

        safeTransferFrom(from, to, newTokenId);
        nfts[newTokenId].owner = to;
        return newTokenId;
    }
}
