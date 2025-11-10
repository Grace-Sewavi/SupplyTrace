SupplyTrace.sol is a Solidity smart contract that enables transparent product verification for small producers.

It allows manufacturers to register product batches on-chain with key details like product ID, IPFS hash, and quality information — while consumers can verify authenticity by scanning a QR code or entering the batch ID.

Built with OpenZeppelin’s AccessControl, the contract ensures only verified manufacturers can upload or update products. It emits clear events (ProductAdded, ProductUpdated, ProductVerified) for seamless frontend integration and traceability tracking.

🔹 Core Functions:

registerProduct() — Adds a new product to the blockchain

updateProductStatus() — Enables or disables a product batch

verifyProduct() — Returns product authenticity and details for consumers

addManufacturer() / removeManufacturer() — Manages access control


⚙️ Purpose: To provide a low-cost, transparent, and tamper-proof verification layer that builds trust between producers and consumers in sustainable supply chains.
