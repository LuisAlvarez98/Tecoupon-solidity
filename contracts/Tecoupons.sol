// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// ganache server
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "./VRFv2Consumer.sol";
/**
    Tec Coupons Contract
    This contract is used to handle a coupon system.
*/
contract Tecoupons is Ownable, ERC721URIStorage, VRFv2Consumer {
    // Enums
    enum CouponType{ FIVE, TEN, FIFTEEN }
    // Events
    event CreateCoupon(address indexed _from,uint256 tokenId );
    event RedeemCoupon(address indexed _from,uint256 tokenId );
    event BurnCoupon(address indexed _from,uint256 tokenId );
    event TransferCoupon(address indexed _from,address indexed _to,uint256 tokenId );
    // Coupon IPFS links
    string constant couponBurntUrl = "https://ipfs.io/ipfs/QmQtqQYkcTRA4uw4mNQVXLX6JXBWWcjrTLs5GdigGynUhU";
    string constant couponFiveUrl = "https://ipfs.io/ipfs/QmaDmxxzGVrNPJrweRvG7A9xj4xaB6FtoiWxypUQ8FBvmH";
    string constant couponTenUrl = "https://ipfs.io/ipfs/QmeieJuqJ7StYnGn6jD3YLi8FhmGPuPq6hDcwCRWBTBhAu";
    string constant couponFifteenUrl = "https://ipfs.io/ipfs/QmTmsxap3viQe4QGSiJaDgpwYQiRFJubeEss1uGhSufJy6";
    // Coupon struct
    struct Coupon {
        CouponType discount;
        bool burned;
        uint256 id;
        string couponCode;
    }
    // Mappings
    mapping (uint256 => address) couponIdToOwner;
    mapping (uint256 => Coupon) couponIdToCoupon;
    // Token Ids
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // The max supply is 999
    uint constant maxSupply = 999;
    uint counter = 0;

    constructor() ERC721("Tecoupon", "TEC") { }
    /**
        isNotBurnt modifier
        checks if the coupon is burnt
    */
    modifier isNotBurnt(uint256 tokenId) {
        require(!couponIdToCoupon[tokenId].burned, "Coupon is already burned");
        _;
    }
    /**
        isCouponOwner modifier
        checks if the coupon is owned by an address.
    */
    modifier isCouponOwner(uint256 tokenId) {
        require(msg.sender == couponIdToOwner[tokenId], "This is not your coupon!");
        _;

    }
    /** 
        createCoupon
        This function transfers a token to an address
    */
    function createCoupon(address _to, string memory tokenURI) public onlyOwner() returns (uint256) {
        require(maxSupply != counter, "Max supply reached!");
        _tokenIds.increment();
        counter++;
        uint256 newItemId = _tokenIds.current();
        _mint(_to, newItemId);
        _setTokenURI(newItemId, tokenURI);
        emit CreateCoupon(_to, newItemId);
                CouponType discount;
        couponIdToOwner[newItemId] = _to;
        couponIdToCoupon[newItemId] = Coupon(CouponType.FIVE, false, newItemId, "testing_code");
        return newItemId;
    }
    /** 
        transferCoupon
        This function transfers a token to an address
    */
    function transferCoupon(address payable _to, uint256 tokenId) public{
        require(msg.sender != _to, "Receiver cannot be sender.");
        require(msg.sender != address(0));
        safeTransferFrom(msg.sender, _to, tokenId);
        emit TransferCoupon(msg.sender, _to, tokenId);
    }
    /**
        burnCoupon function
        burns the coupon and sets the new tokenURI
    */
    function burnCoupon(uint256 tokenId) private isNotBurnt(tokenId){
        couponIdToCoupon[tokenId].burned = true;
        emit BurnCoupon(msg.sender, tokenId);
        _setTokenURI(tokenId, couponBurntUrl);
    }
    /**
        redeemCoupon function
        this function is used to redeem and burn the coupon when it is used.
    */
    function redeemCoupon(uint256 tokenId) public isNotBurnt(tokenId) onlyOwner(){
        emit RedeemCoupon(msg.sender, tokenId);
        burnCoupon(tokenId);
    }
    /**
        getCoupon function
        returns coupon code
    */
    function getCoupon(uint256 tokenId) public view isCouponOwner(tokenId) returns(string memory){
        return couponIdToCoupon[tokenId].couponCode;
    }

}
