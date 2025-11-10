// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.20;  
  
/**  
 * @title SupplyChainTraceability  
 * @dev Blockchain-based traceability contract for small producers.  
 * Producers register products (batch codes, hashes, quality, etc.)  
 * Consumers verify authenticity using QR or code lookup.  
 */  
  
import "@openzeppelin/contracts/access/AccessControl.sol";  
  
contract SupplyTrace is AccessControl {  
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");  
  
    struct Product {  
        string productId;       // Unique batch ID or code  
        string productName;     // e.g. "Organic Cocoa Beans"  
        string ipfsHash;        // Metadata stored off-chain (IPFS CID)  
        string qualityInfo;     // Basic info like "Grade A", "Organic"  
        bool active;            // Product status: valid/disabled  
        uint256 createdAt;      // Timestamp when added  
        address manufacturer;   // Address of uploader  
    }  
  
    // Mapping from product code → product data  
    mapping(string => Product) private products;  
  
    // Events for transparency  
    event ProductAdded(string indexed productId, address indexed manufacturer);  
    event ProductUpdated(string indexed productId, bool active);  
    event ProductVerified(string indexed productId, bool valid, address verifier);  
  
    constructor() {  
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);  
    }  
  
    // -----------------------------------------  
    // 🔹 MANUFACTURER PHASE FUNCTIONS  
    // -----------------------------------------  
  
    /**  
     * @notice Register a new product batch on-chain  
     * @param _productId Unique ID / Batch Code  
     * @param _productName Product name or label  
     * @param _ipfsHash IPFS CID for metadata/certifications  
     * @param _qualityInfo Quality or sustainability notes  
     */  
    function registerProduct(  
        string memory _productId,  
        string memory _productName,  
        string memory _ipfsHash,  
        string memory _qualityInfo  
    ) external onlyRole(MANUFACTURER_ROLE) {  
        require(bytes(_productId).length > 0, "Invalid product ID");  
        require(products[_productId].createdAt == 0, "Product already exists");  
  
        products[_productId] = Product({  
            productId: _productId,  
            productName: _productName,  
            ipfsHash: _ipfsHash,  
            qualityInfo: _qualityInfo,  
            active: true,  
            createdAt: block.timestamp,  
            manufacturer: msg.sender  
        });  
  
        emit ProductAdded(_productId, msg.sender);  
    }  
  
    /**  
     * @notice Update product status (enable/disable)  
     * @param _productId Product batch ID  
     * @param _status true for active, false for disabled  
     */  
    function updateProductStatus(string memory _productId, bool _status)  
        external  
        onlyRole(MANUFACTURER_ROLE)  
    {  
        require(products[_productId].createdAt != 0, "Product not found");  
        require(products[_productId].manufacturer == msg.sender, "Not your product");  
  
        products[_productId].active = _status;  
        emit ProductUpdated(_productId, _status);  
    }  
  
    // -----------------------------------------  
    // 🔍 CONSUMER VERIFICATION PHASE  
    // -----------------------------------------  
  
    /**  
     * @notice Verify product authenticity by ID  
     * @param _productId Product batch code scanned by consumer  
     */  
    function verifyProduct(string memory _productId)  
        external  
        view  
        returns (  
            bool valid,  
            string memory name,  
            string memory quality,  
            string memory ipfs,  
            address manufacturer,  
            uint256 timestamp  
        )  
    {  
        Product memory product = products[_productId];  
        if (product.createdAt == 0 || !product.active) {  
            return (false, "", "", "", address(0), 0);  
        }  
        return (  
            true,  
            product.productName,  
            product.qualityInfo,  
            product.ipfsHash,  
            product.manufacturer,  
            product.createdAt  
        );  
    }  
  
    // -----------------------------------------  
    // ⚙️ ADMIN FUNCTIONS  
    // -----------------------------------------  
  
    /**  
     * @notice Add manufacturer access  
     * @param _manufacturer Address to grant manufacturer role  
     */  
    function addManufacturer(address _manufacturer) external onlyRole(DEFAULT_ADMIN_ROLE) {  
        _grantRole(MANUFACTURER_ROLE, _manufacturer);  
    }  
  
    /**  
     * @notice Remove manufacturer access  
     * @param _manufacturer Address to revoke manufacturer role  
     */  
    function removeManufacturer(address _manufacturer) external onlyRole(DEFAULT_ADMIN_ROLE) {  
        _revokeRole(MANUFACTURER_ROLE, _manufacturer);  
    }  
}
