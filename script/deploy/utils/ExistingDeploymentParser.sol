// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import "eigenlayer-contracts/src/contracts/core/StrategyManager.sol";
import "eigenlayer-contracts/src/contracts/core/Slasher.sol";
import "eigenlayer-contracts/src/contracts/core/DelegationManager.sol";
import "eigenlayer-contracts/src/contracts/core/AVSDirectory.sol";
import "eigenlayer-contracts/src/contracts/core/RewardsCoordinator.sol";

import "eigenlayer-contracts/src/contracts/strategies/StrategyBase.sol";

import "eigenlayer-contracts/src/contracts/pods/EigenPod.sol";
import "eigenlayer-contracts/src/contracts/pods/EigenPodManager.sol";
import "eigenlayer-contracts/src/contracts/pods/DelayedWithdrawalRouter.sol";

import "eigenlayer-contracts/src/contracts/permissions/PauserRegistry.sol";

import "eigenlayer-contracts/src/test/mocks/EmptyContract.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract ExistingDeploymentParser is Script, Test {

    // EigenLayer Contracts
    ProxyAdmin public eigenLayerProxyAdmin;
    PauserRegistry public eigenLayerPauserReg;
    Slasher public slasher;
    Slasher public slasherImplementation;
    AVSDirectory public avsDirectory;
    AVSDirectory public avsDirectoryImplementation;
    DelegationManager public delegationManager;
    DelegationManager public delegationManagerImplementation;
    StrategyManager public strategyManager;
    StrategyManager public strategyManagerImplementation;
    EigenPodManager public eigenPodManager;
    EigenPodManager public eigenPodManagerImplementation;
    DelayedWithdrawalRouter public delayedWithdrawalRouter;
    DelayedWithdrawalRouter public delayedWithdrawalRouterImplementation;
    RewardsCoordinator public rewardsCoordinator;
    RewardsCoordinator public rewardsCoordinatorImplementation;
    UpgradeableBeacon public eigenPodBeacon;
    EigenPod public eigenPodImplementation;
    StrategyBase public baseStrategyImplementation;

    EmptyContract public emptyContract;

    address executorMultisig;
    address operationsMultisig;

// strategies deployed
    StrategyBase[] public deployedStrategyArray;

    function _parseDeployedContracts(string memory existingDeploymentInfoPath) internal {
// read and log the chainID
        uint256 currentChainId = block.chainid;
        emit log_named_uint("You are parsing on ChainID", currentChainId);

// READ JSON CONFIG DATA
        string memory existingDeploymentData = vm.readFile(existingDeploymentInfoPath);

// check that the chainID matches the one in the config
        uint256 configChainId = stdJson.readUint(existingDeploymentData, ".chainInfo.chainId");
        require(configChainId == currentChainId, "You are on the wrong chain for this config");

// read all of the deployed addresses
        executorMultisig = stdJson.readAddress(existingDeploymentData, ".parameters.executorMultisig");
        operationsMultisig = stdJson.readAddress(existingDeploymentData, ".parameters.operationsMultisig");

        eigenLayerProxyAdmin = ProxyAdmin(stdJson.readAddress(existingDeploymentData, ".addresses.eigenLayerProxyAdmin"));
        slasher = Slasher(stdJson.readAddress(existingDeploymentData, ".addresses.slasher"));
        slasherImplementation = Slasher(stdJson.readAddress(existingDeploymentData, ".addresses.slasherImplementation"));
        delegationManager = DelegationManager(stdJson.readAddress(existingDeploymentData, ".addresses.delegationManager"));
        delegationManagerImplementation = DelegationManager(stdJson.readAddress(existingDeploymentData, ".addresses.delegationManagerImplementation"));
        avsDirectory = AVSDirectory(stdJson.readAddress(existingDeploymentData, ".addresses.avsDirectory"));
        avsDirectoryImplementation = AVSDirectory(stdJson.readAddress(existingDeploymentData, ".addresses.avsDirectoryImplementation"));
        rewardsCoordinator = RewardsCoordinator(stdJson.readAddress(existingDeploymentData, ".addresses.rewardsCoordinator"));
        rewardsCoordinatorImplementation = RewardsCoordinator(stdJson.readAddress(existingDeploymentData, ".addresses.rewardsCoordinatorImplementation"));
        strategyManager = StrategyManager(stdJson.readAddress(existingDeploymentData, ".addresses.strategyManager"));
        strategyManagerImplementation = StrategyManager(stdJson.readAddress(existingDeploymentData, ".addresses.strategyManagerImplementation"));
        eigenPodManager = EigenPodManager(stdJson.readAddress(existingDeploymentData, ".addresses.eigenPodManager"));
        eigenPodManagerImplementation = EigenPodManager(stdJson.readAddress(existingDeploymentData, ".addresses.eigenPodManagerImplementation"));
        delayedWithdrawalRouter = DelayedWithdrawalRouter(stdJson.readAddress(existingDeploymentData, ".addresses.delayedWithdrawalRouter"));
        delayedWithdrawalRouterImplementation =
                        DelayedWithdrawalRouter(stdJson.readAddress(existingDeploymentData, ".addresses.delayedWithdrawalRouterImplementation"));
        eigenPodBeacon = UpgradeableBeacon(stdJson.readAddress(existingDeploymentData, ".addresses.eigenPodBeacon"));
        eigenPodImplementation = EigenPod(payable(stdJson.readAddress(existingDeploymentData, ".addresses.eigenPodImplementation")));
        baseStrategyImplementation = StrategyBase(stdJson.readAddress(existingDeploymentData, ".addresses.baseStrategyImplementation"));
        emptyContract = EmptyContract(stdJson.readAddress(existingDeploymentData, ".addresses.emptyContract"));

    }
}