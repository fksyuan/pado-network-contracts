// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";
import {IDataMgt, DataInfo, PriceInfo, EncryptionSchema, DataStatus} from "./interface/IDataMgt.sol"; 
/**
 * @title DataMgt
 * @notice DataMgt - Data Management Contract.
 */
contract DataMgt is Initializable, IDataMgt{
    uint256 private _registryCount;
    mapping(bytes32 dataId => DataInfo dataInfo) private _dataInfos;
    bytes32[] private _dataIds;

    mapping(address owner => bytes32[] dataIdList) private _dataIdListPerOwner;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    /// constructor() {
    ///     _disableInitializers();
    /// }

    function initialize() external initializer {
        _registryCount = 0;
    }

    /**
     * @notice Data Provider prepare to register confidential data to PADO Network.
     * @param encryptionSchema EncryptionSchema
     * @return dataId and publicKeys data id and public keys
     */
    function prepareRegistry(
        EncryptionSchema calldata encryptionSchema
    ) external returns (bytes32 dataId, bytes[] memory publicKeys) {
        dataId = keccak256(abi.encode(encryptionSchema, _registryCount));
        _registryCount++;

        // TODO
        publicKeys = new bytes[](1);
        publicKeys[0] = bytes("test");

        bytes32[] memory workerIds = new bytes32[](1);
        workerIds[0] = keccak256(abi.encode(msg.sender));

        DataInfo memory dataInfo = DataInfo({
                dataId: dataId,
                dataTag: "",
                priceInfo: PriceInfo({tokenSymbol:"", price:0}),
                dataContent: new bytes(0),
                encryptionSchema: encryptionSchema,
                workerIds: workerIds,
                registeredTimestamp: uint64(block.timestamp),
                owner: msg.sender,
                status: DataStatus.REGISTERING
            });
        _dataInfos[dataId] = dataInfo;
        _dataIds.push(dataId);
        _dataIdListPerOwner[msg.sender].push(dataId);

        emit PrepareRegistry(dataId, publicKeys);
    }

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
    ) external returns (bytes32) {
        require(_dataInfos[dataId].status == DataStatus.REGISTERING, "invalid dataId");

        DataInfo storage dataInfo = _dataInfos[dataId];

        dataInfo.dataTag = dataTag;
        dataInfo.priceInfo = priceInfo;
        dataInfo.dataContent = dataContent;

        dataInfo.status = DataStatus.REGISTERED;

        return dataId;
    }
    

    /**
     * @notice Get all data registered by Data Provider
     * @return return all data
     */
    function getAllData(
    ) external view returns (DataInfo[] memory) {
        uint256 dataIdLength = _dataIds.length;

        DataInfo[] memory dataInfoList = new DataInfo[](dataIdLength);
        for (uint256 i = 0; i < dataIdLength; i++) {
            dataInfoList[i] = _dataInfos[_dataIds[i]];
        }

        return dataInfoList;
    }

    /**
     * @notice Get data by owner
     * @param owner The owner of data
     * @return return data owned by the owner
     */
    function getDataByOwner(
        address owner
    ) external view returns (DataInfo[] memory) {
        bytes32[] storage dataIdList = _dataIdListPerOwner[owner];

        DataInfo[] memory allDataInfo = new DataInfo[](dataIdList.length);
        for (uint256 i = 0; i < dataIdList.length; i++) {
            allDataInfo[i] = _dataInfos[dataIdList[i]];
        }
        return allDataInfo;
    }

    /**
     * @notice Get data by dataId
     * @param dataId The identifier of the data
     * @return return the data 
     */
    function getDataById(
        bytes32 dataId
    ) external view returns (DataInfo memory) {
        require(_dataInfos[dataId].dataId != 0, "data not exist");

        return _dataInfos[dataId];
    }

    /**
     * @notice Delete data by dataId
     * @param dataId The identifier of the data
     */
    function deleteDataById(
        bytes32 dataId
    ) external {
        DataInfo storage dataInfo = _dataInfos[dataId];
        require(dataInfo.dataId != 0, "data not exist");
        require(dataInfo.status != DataStatus.DELETED, "data already deleted");

        dataInfo.status = DataStatus.DELETED;
    }
}
