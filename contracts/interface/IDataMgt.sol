// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
/**
 * @notice A struct representing a concrete price of a piece of data
 */
struct PriceInfo {
    string tokenSymbol; // The token symbol of price
    uint256 price;  // The price of data 
}

/**
 * @notice A enum representing data staus
 */
enum DataStatus {
    NEVER_USED,
    REGISTERING,
    REGISTERED,
    DELETED
}

/**
 * @notice A struct representing a piece of data
 */
struct EncryptionSchema {
    uint32 t; // threshold
    uint32 n; // total amount of nodes
}

/**
 * @notice A struct representing a piece of data
 */
struct DataInfo {
    bytes32 dataId; // The identifier of the data
    string dataTag; // The tag of the data
    PriceInfo priceInfo; // The price of the data
    bytes dataContent; // The content of the data
    EncryptionSchema encryptionSchema; // The encryption schema
    bytes32[] workerIds; // The workerIds of workers participanting in  encrypting the data
    uint64 registeredTimestamp; // The timestamp at which the data was registered
    address owner; // The owner of the data
    DataStatus status; // The status of the data
}

/**
 * @title IDataMgt
 * @notice DataMgt - Data Management interface.
 */
interface IDataMgt {
    // emit in prepareRegistry
    event PrepareRegistry(bytes32 dataId, bytes[] publicKeys);

    // emit in register
    event Register(bytes32);
    /**
     * @notice Data Provider prepare to register confidential data to PADO Network.
     * @param encryptionSchema EncryptionSchema
     * @return dataId and publicKeys Data id and public keys
     */
    function prepareRegistry(
        EncryptionSchema calldata encryptionSchema
    ) external returns (bytes32 dataId, bytes[] memory publicKeys);

    /**
     * @notice Data Provider register confidential data to PADO Network.
     * @param dataId Data id for registry, returned by prepareRegistry.
     * @param dataTag The tag of data, providing basic information about data.
     * @param priceInfo The price infomation of data.
     * @param dataContent The content of data.
     * @return The UID of the data
     */
    function register(
        bytes32 dataId,
        string calldata dataTag,
        PriceInfo calldata priceInfo,
        bytes calldata dataContent
    ) external returns (bytes32);
    

    /**
     * @notice Get all data registered by Data Provider
     * @return return all data
     */
    function getAllData(
    ) external view returns (DataInfo[] memory);

    /**
     * @notice Get data by owner
     * @param owner The owner of data
     * @return return data owned by the owner
     */
    function getDataByOwner(
        address owner
    ) external view returns (DataInfo[] memory);

    /**
     * @notice Get data by dataId
     * @param dataId The identifier of the data
     * @return return the data 
     */
    function getDataById(
        bytes32 dataId
    ) external view returns (DataInfo memory);

    /**
     * @notice Delete data by dataId
     * @param dataId The identifier of the data
     */
    function deleteDataById(
        bytes32 dataId
    ) external;
}