// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IFeeMgt} from "./interface/IFeeMgt.sol";
import {ITaskMgt} from "./interface/ITaskMgt.sol";
import {IRouter, IRouterUpdater} from "./interface/IRouter.sol";
import {FeeTokenInfo, Balance, TaskStatus} from "./types/Common.sol";

/**
 * @title FeeMgt
 * @notice FeeMgt - Fee Management Contract.
 */
contract FeeMgt is IFeeMgt, IRouterUpdater, OwnableUpgradeable {
    // router
    IRouter public router;

    // tokenSymbol => FeeTokenInfo 
    mapping(string symbol => FeeTokenInfo feeTokenInfo) private _feeTokenInfoForSymbol;

    // tokenSymbol[]
    string[] private _symbolList;

    // eoa => tokenSymbol => balance
    mapping(address eoa => mapping(string tokenSymbol => Balance balance)) private _balanceForEOA;

    // taskId => amount
    mapping(bytes32 taskId => uint256 amount) private _lockedAmountForTaskId;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    /**
     * @notice Initial FeeMgt.
     * @param _router The Router
     * @param computingPriceForETH The computing price for ETH.
     * @param contractOwner The owner of the contract
     */
    function initialize(IRouter _router, uint256 computingPriceForETH, address contractOwner) public initializer {
        router = _router;
        _addFeeToken("ETH", address(0), computingPriceForETH);
        _transferOwnership(contractOwner);
    }

    /**
     * @notice TaskMgt contract request transfer tokens.
     * @param tokenSymbol The token symbol
     * @param amount The amount of tokens to be transfered
     */
    function transferToken(
        address from,
        string calldata tokenSymbol,
        uint256 amount
    ) payable external onlyTaskMgt {
        require(isSupportToken(tokenSymbol), "FeeMgt.transferToken: not supported token");
        if (_isETH(tokenSymbol)) {
            require(amount == msg.value, "FeeMgt.transferToken: amount is not correct");
        }
        else {
            require(msg.value == 0, "FeeMgt.transferToken: msg.value should be zero");
            FeeTokenInfo storage feeTokenInfo = _feeTokenInfoForSymbol[tokenSymbol];
            
            address tokenAddress = feeTokenInfo.tokenAddress;
            IERC20(tokenAddress).transferFrom(from, address(this), amount);
        }

        Balance storage balance = _balanceForEOA[from][tokenSymbol];

        balance.free += amount;

        emit TokenTransfered(from, tokenSymbol, amount);
    }

    /**
     * @notice TaskMgt contract request transfer tokens.
     * @param to The address to which token is withdrawn.
     * @param tokenSymbol The token symbol
     * @param amount The amount of tokens to be transfered
     */
    function withdrawToken(
        address to,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        require(isSupportToken(tokenSymbol), "FeeMgt.withdrawToken: not supported token");

        Balance storage balance = _balanceForEOA[msg.sender][tokenSymbol];
        require(balance.free >= amount, "FeeMgt.withdrawToken: insufficient free balance");
        balance.free -= amount;
        if (_isETH(tokenSymbol)) {
            (bool res, )  = payable(address(to)).call{value: amount}(new bytes(0));
            require(res, "FeeMgt.withdrawToken: call error");
        }
        else {
            FeeTokenInfo storage feeTokenInfo = _feeTokenInfoForSymbol[tokenSymbol];
            
            address tokenAddress = feeTokenInfo.tokenAddress;
            IERC20(tokenAddress).transfer(to, amount);
        }

        emit TokenWithdrawn(to, tokenSymbol, amount);
    }

    /**
     * @notice TaskMgt contract request locking fee.
     * @param taskId The task id.
     * @param submitter The submitter of the task.
     * @param tokenSymbol The fee token symbol.
     * @param toLockAmount The amount of fee to lock.
     * @return Returns true if the locking is successful.
     */
    function lock(
        bytes32 taskId,
        address submitter,
        string calldata tokenSymbol,
        uint256 toLockAmount 
    ) external onlyTaskMgt returns (bool) {
        require(isSupportToken(tokenSymbol), "FeeMgt.lock: not supported token");

        Balance storage balance = _balanceForEOA[submitter][tokenSymbol];

        require(balance.free >= toLockAmount, "FeeMgt.lock: Insufficient free balance");

        balance.free -= toLockAmount;
        balance.locked += toLockAmount;
        _lockedAmountForTaskId[taskId] = toLockAmount;

        emit FeeLocked(taskId, tokenSymbol, toLockAmount);
        return true;
    }

    /**
     * @notice TaskMgt contract request unlocking fee.
     * @param taskId The task id.
     * @param submitter The submitter of the task.
     * @param tokenSymbol The fee token symbol.
     * @return Return true if the unlocking is successful.
     */
    function unlock(
        bytes32 taskId,
        address submitter,
        string calldata tokenSymbol
    ) external onlyTaskMgt returns (bool) {
        require(isSupportToken(tokenSymbol), "FeeMgt.unlock: not supported token");
        uint256 toUnlockAmount = _lockedAmountForTaskId[taskId];
        require(toUnlockAmount > 0, "FeeMgt.unlock: locked amount is zero");

        Balance storage balance = _balanceForEOA[submitter][tokenSymbol];
        require(balance.locked >= toUnlockAmount, "FeeMgt.unlock: Insufficient locked balance");

        balance.free += toUnlockAmount;
        balance.locked -= toUnlockAmount;
        _lockedAmountForTaskId[taskId] -= toUnlockAmount;

        emit FeeUnlocked(taskId, tokenSymbol, toUnlockAmount);
        return true;
    }


    /**
     * @notice TaskMgt contract request pay workers.
     * @param taskId The task id.
     * @param submitter The task submitter.
     * @param workerOwner The owner of the worker.
     * @param tokenSymbol The symbol of the token.
     */
    function payWorker(
        bytes32 taskId,
        address submitter,
        address workerOwner,
        string calldata tokenSymbol
    ) external onlyTaskMgt {
        require(isSupportToken(tokenSymbol), "FeeMgt.payWorker: not supported token");
        uint256 computingPrice = _feeTokenInfoForSymbol[tokenSymbol].computingPrice;
        require(computingPrice > 0, "FeeMgt.payWorker: computing price is not set");
        uint256 lockedAmount = _lockedAmountForTaskId[taskId];
        require(lockedAmount >= computingPrice, "FeeMgt.payWorker: insufficient lockedAmount");
        _lockedAmountForTaskId[taskId] -= computingPrice;

        _balanceForEOA[submitter][tokenSymbol].locked -= computingPrice;
        _balanceForEOA[workerOwner][tokenSymbol].free += computingPrice;

    }

    /**
     * @notice TaskMgt contract request settlement fee.
     * @param taskId The task id.
     * @param submitter The submitter of the task.
     * @param tokenSymbol The fee token symbol.
     * @param dataPrice The data price of the task.
     * @param dataProviders The address of data providers which provide data to the task.
     * @return Returns true if the settlement is successful.
     */
    function settle(
        bytes32 taskId,
        address submitter,
        string calldata tokenSymbol,
        uint256 dataPrice,
        address[] calldata dataProviders
    ) external onlyTaskMgt returns (bool) {
        require(isSupportToken(tokenSymbol), "FeeMgt.settle: not supported token");

        uint256 lockedAmount = _lockedAmountForTaskId[taskId];

        Balance storage balance = _balanceForEOA[submitter][tokenSymbol];

        uint256 expectedBalance = dataPrice * dataProviders.length;

        require(expectedBalance <= balance.locked, "FeeMgt.settle: insufficient locked balance");
        require(lockedAmount >= expectedBalance, "FeeMgt.settle: locked not enough");

        if (expectedBalance > 0) {
            _settle(
                taskId,
                submitter,
                tokenSymbol,
                dataPrice,
                dataProviders
            );
        }
        if (lockedAmount > expectedBalance) {
            uint256 toReturnAmount = lockedAmount - expectedBalance;
            balance.locked -= toReturnAmount;
            balance.free += toReturnAmount;
            
            emit FeeUnlocked(taskId, tokenSymbol, toReturnAmount);
        }

        return true;
    }

    /**
     * @notice Add the fee token.
     * @param tokenSymbol The new fee token symbol.
     * @param tokenAddress The new fee token address.
     * @param computingPrice The computing price for the token.
     * @return Returns true if the adding is successful.
     */
    function addFeeToken(string calldata tokenSymbol, address tokenAddress, uint256 computingPrice) external onlyOwner returns (bool) {
        return _addFeeToken(tokenSymbol, tokenAddress, computingPrice);
    }

    /**
     * @notice Update the fee token.
     * @param tokenSymbol The fee token symbol.
     * @param tokenAddress The fee token address.
     * @param computingPrice The computing price for the token.
     * @return Returns true if the updating is successful.
     */
    function updateFeeToken(string calldata tokenSymbol, address tokenAddress, uint256 computingPrice) external onlyOwner returns (bool) {
        require(bytes(tokenSymbol).length > 0, "FeeMgt.updateFeeToken: tokenSymbol can not be empty");
        FeeTokenInfo storage feeTokenInfo = _feeTokenInfoForSymbol[tokenSymbol];
        require(bytes(feeTokenInfo.symbol).length > 0, "FeeMgt.updateFeeToken: fee token does not exist");

        if (tokenAddress != address(0)) {
            feeTokenInfo.tokenAddress = tokenAddress;
        }
        if (computingPrice != 0) {
            feeTokenInfo.computingPrice = computingPrice;
        }
        emit FeeTokenUpdated(tokenSymbol, tokenAddress, computingPrice);
        return true;
    }

    /**
     * @notice Delete the fee token.
     * @param tokenSymbol The fee token symbol.
     */
    function deleteFeeToken(string calldata tokenSymbol) external onlyOwner {
        require(bytes(_feeTokenInfoForSymbol[tokenSymbol].symbol).length > 0, "FeeMgt.deleteFeeToken: token does not exist");
        delete _feeTokenInfoForSymbol[tokenSymbol];

        emit FeeTokenDeleted(tokenSymbol);
    }

    /**
     * @notice Add the fee token.
     * @param tokenSymbol The new fee token symbol.
     * @param tokenAddress The new fee token address.
     * @param computingPrice The computing price for the token.
     * @return Returns true if the adding is successful.
     */
    function _addFeeToken(string memory tokenSymbol, address tokenAddress, uint256 computingPrice) internal returns (bool) {
        require(bytes(_feeTokenInfoForSymbol[tokenSymbol].symbol).length == 0, "FeeMgt._addFeeToken: token symbol already exists");
        require(bytes(tokenSymbol).length > 0, "FeeMgt._addFeeToken: tokenSymbol can not be empty");
        require(_isETH(tokenSymbol) || tokenAddress != address(0), "FeeMgt._addFeeToken: tokenAddress can not be empty");
        require(computingPrice > 0, "FeeMgt._addFeeToken: computingPrice can not be zero");

        FeeTokenInfo memory feeTokenInfo = FeeTokenInfo({
            symbol: tokenSymbol,
            tokenAddress: tokenAddress,
            computingPrice: computingPrice
        });
        _feeTokenInfoForSymbol[tokenSymbol] = feeTokenInfo;
        _symbolList.push(tokenSymbol);

        emit FeeTokenAdded(tokenSymbol, tokenAddress, computingPrice);
        return true;
    }

    /**
     * @notice Get the all fee tokens.
     * @return Returns the all fee tokens info.
     */
    function getFeeTokens() external view returns (FeeTokenInfo[] memory) {
        uint256 symbolListLength = _symbolList.length;
        FeeTokenInfo[] memory tokenInfos = new FeeTokenInfo[](symbolListLength);

        for (uint256 i = 0; i < _symbolList.length; i++) {
            string storage symbol = _symbolList[i];

            tokenInfos[i] = _feeTokenInfoForSymbol[symbol]; 
        }

        return tokenInfos;
    }

    /**
     * @notice Get fee token by token symbol.
     * @param tokenSymbol The token symbol.
     * @return Returns the fee token.
     */
    function getFeeTokenBySymbol(string calldata tokenSymbol) external view returns (FeeTokenInfo memory) {
        FeeTokenInfo storage info = _feeTokenInfoForSymbol[tokenSymbol]; 

        require(bytes(info.symbol).length > 0, "FeeMgt.getFeeTokenBySymbol: fee token does not exist");
        return info;
    }

    /**
     * @notice Determine whether a token can pay the handling fee.
     * @return Returns true if a token can pay fee, otherwise returns false.
     */
    function isSupportToken(string calldata tokenSymbol) public view returns (bool) {
        if (_isETH(tokenSymbol)) {
            return true;
        }
        return bytes(_feeTokenInfoForSymbol[tokenSymbol].symbol).length > 0;
    }

    /**
     * @notice Get balance info.
     * @param eoa The address of EOA
     * @param tokenSymbol The token symbol for the EOA
     * @return Balance for the EOA
     */
    function getBalance(address eoa, string calldata tokenSymbol) external view returns (Balance memory) {
        return _balanceForEOA[eoa][tokenSymbol];
    }

    /**
     * @notice Whether the token symbol is ETH
     * @param tokenSymbol The token symbol
     * @return True if the token symbol is ETH, else false
     */
    function _isETH(string memory tokenSymbol) internal pure returns (bool) {
        return keccak256(bytes(tokenSymbol)) == keccak256(bytes("ETH"));
    }

    /**
     * @notice TaskMgt contract request settlement fee.
     * @param taskId The task id.
     * @param submitter The submitter of the task.
     * @param tokenSymbol The fee token symbol.
     * @param dataPrice The data price of the task.
     * @param dataProviders The address of data providers which provide data to the task.
     */
    function _settle(
        bytes32 taskId,
        address submitter,
        string memory tokenSymbol,
        uint256 dataPrice,
        address[] memory dataProviders
    ) internal {
        uint256 settledFee = 0;

        for (uint256 i = 0; i < dataProviders.length; i++) {
            _balanceForEOA[dataProviders[i]][tokenSymbol].free += dataPrice;
            settledFee += dataPrice;
        }
        _balanceForEOA[submitter][tokenSymbol].locked -= settledFee;
        emit FeeSettled(taskId, tokenSymbol, settledFee);
    }

    modifier onlyTaskMgt() {
        require(msg.sender == address(router.getTaskMgt()), "FeeMgt.onlyTaskMgt: only task mgt allowed to call");
        _;
    }

    /**
     * @notice updateRouter
     * @param _router The router
     */
    function updateRouter(IRouter _router) external onlyOwner {
        IRouter oldRouter = router;
        router = _router;
        emit RouterUpdated(oldRouter, _router);
    }
}
