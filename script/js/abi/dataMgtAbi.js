const dataMgtAbi = [
    {
        "type": "function",
        "name": "deleteDataById",
        "inputs": [
            {
                "name": "dataId",
                "type": "bytes32",
                "internalType": "bytes32"
            }
        ],
        "outputs": [],
        "stateMutability": "nonpayable"
    },
    {
        "type": "function",
        "name": "getAllData",
        "inputs": [],
        "outputs": [
            {
                "name": "",
                "type": "tuple[]",
                "internalType": "struct DataInfo[]",
                "components": [
                    {
                        "name": "dataId",
                        "type": "bytes32",
                        "internalType": "bytes32"
                    },
                    {
                        "name": "dataTag",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "priceInfo",
                        "type": "tuple",
                        "internalType": "struct PriceInfo",
                        "components": [
                            {
                                "name": "tokenSymbol",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "price",
                                "type": "uint256",
                                "internalType": "uint256"
                            }
                        ]
                    },
                    {
                        "name": "dataContent",
                        "type": "bytes",
                        "internalType": "bytes"
                    },
                    {
                        "name": "encryptionSchema",
                        "type": "tuple",
                        "internalType": "struct EncryptionSchema",
                        "components": [
                            {
                                "name": "t",
                                "type": "uint32",
                                "internalType": "uint32"
                            },
                            {
                                "name": "n",
                                "type": "uint32",
                                "internalType": "uint32"
                            }
                        ]
                    },
                    {
                        "name": "workerIds",
                        "type": "bytes32[]",
                        "internalType": "bytes32[]"
                    },
                    {
                        "name": "registeredTimestamp",
                        "type": "uint64",
                        "internalType": "uint64"
                    },
                    {
                        "name": "owner",
                        "type": "address",
                        "internalType": "address"
                    },
                    {
                        "name": "status",
                        "type": "uint8",
                        "internalType": "enum DataStatus"
                    }
                ]
            }
        ],
        "stateMutability": "view"
    },
    {
        "type": "function",
        "name": "getDataById",
        "inputs": [
            {
                "name": "dataId",
                "type": "bytes32",
                "internalType": "bytes32"
            }
        ],
        "outputs": [
            {
                "name": "",
                "type": "tuple",
                "internalType": "struct DataInfo",
                "components": [
                    {
                        "name": "dataId",
                        "type": "bytes32",
                        "internalType": "bytes32"
                    },
                    {
                        "name": "dataTag",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "priceInfo",
                        "type": "tuple",
                        "internalType": "struct PriceInfo",
                        "components": [
                            {
                                "name": "tokenSymbol",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "price",
                                "type": "uint256",
                                "internalType": "uint256"
                            }
                        ]
                    },
                    {
                        "name": "dataContent",
                        "type": "bytes",
                        "internalType": "bytes"
                    },
                    {
                        "name": "encryptionSchema",
                        "type": "tuple",
                        "internalType": "struct EncryptionSchema",
                        "components": [
                            {
                                "name": "t",
                                "type": "uint32",
                                "internalType": "uint32"
                            },
                            {
                                "name": "n",
                                "type": "uint32",
                                "internalType": "uint32"
                            }
                        ]
                    },
                    {
                        "name": "workerIds",
                        "type": "bytes32[]",
                        "internalType": "bytes32[]"
                    },
                    {
                        "name": "registeredTimestamp",
                        "type": "uint64",
                        "internalType": "uint64"
                    },
                    {
                        "name": "owner",
                        "type": "address",
                        "internalType": "address"
                    },
                    {
                        "name": "status",
                        "type": "uint8",
                        "internalType": "enum DataStatus"
                    }
                ]
            }
        ],
        "stateMutability": "view"
    },
    {
        "type": "function",
        "name": "getDataByOwner",
        "inputs": [
            {
                "name": "owner",
                "type": "address",
                "internalType": "address"
            }
        ],
        "outputs": [
            {
                "name": "",
                "type": "tuple[]",
                "internalType": "struct DataInfo[]",
                "components": [
                    {
                        "name": "dataId",
                        "type": "bytes32",
                        "internalType": "bytes32"
                    },
                    {
                        "name": "dataTag",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "priceInfo",
                        "type": "tuple",
                        "internalType": "struct PriceInfo",
                        "components": [
                            {
                                "name": "tokenSymbol",
                                "type": "string",
                                "internalType": "string"
                            },
                            {
                                "name": "price",
                                "type": "uint256",
                                "internalType": "uint256"
                            }
                        ]
                    },
                    {
                        "name": "dataContent",
                        "type": "bytes",
                        "internalType": "bytes"
                    },
                    {
                        "name": "encryptionSchema",
                        "type": "tuple",
                        "internalType": "struct EncryptionSchema",
                        "components": [
                            {
                                "name": "t",
                                "type": "uint32",
                                "internalType": "uint32"
                            },
                            {
                                "name": "n",
                                "type": "uint32",
                                "internalType": "uint32"
                            }
                        ]
                    },
                    {
                        "name": "workerIds",
                        "type": "bytes32[]",
                        "internalType": "bytes32[]"
                    },
                    {
                        "name": "registeredTimestamp",
                        "type": "uint64",
                        "internalType": "uint64"
                    },
                    {
                        "name": "owner",
                        "type": "address",
                        "internalType": "address"
                    },
                    {
                        "name": "status",
                        "type": "uint8",
                        "internalType": "enum DataStatus"
                    }
                ]
            }
        ],
        "stateMutability": "view"
    },
    {
        "type": "function",
        "name": "initialize",
        "inputs": [],
        "outputs": [],
        "stateMutability": "nonpayable"
    },
    {
        "type": "function",
        "name": "prepareRegistry",
        "inputs": [
            {
                "name": "encryptionSchema",
                "type": "tuple",
                "internalType": "struct EncryptionSchema",
                "components": [
                    {
                        "name": "t",
                        "type": "uint32",
                        "internalType": "uint32"
                    },
                    {
                        "name": "n",
                        "type": "uint32",
                        "internalType": "uint32"
                    }
                ]
            }
        ],
        "outputs": [
            {
                "name": "dataId",
                "type": "bytes32",
                "internalType": "bytes32"
            },
            {
                "name": "publicKeys",
                "type": "bytes[]",
                "internalType": "bytes[]"
            }
        ],
        "stateMutability": "nonpayable"
    },
    {
        "type": "function",
        "name": "register",
        "inputs": [
            {
                "name": "dataId",
                "type": "bytes32",
                "internalType": "bytes32"
            },
            {
                "name": "dataTag",
                "type": "string",
                "internalType": "string"
            },
            {
                "name": "priceInfo",
                "type": "tuple",
                "internalType": "struct PriceInfo",
                "components": [
                    {
                        "name": "tokenSymbol",
                        "type": "string",
                        "internalType": "string"
                    },
                    {
                        "name": "price",
                        "type": "uint256",
                        "internalType": "uint256"
                    }
                ]
            },
            {
                "name": "dataContent",
                "type": "bytes",
                "internalType": "bytes"
            }
        ],
        "outputs": [
            {
                "name": "",
                "type": "bytes32",
                "internalType": "bytes32"
            }
        ],
        "stateMutability": "nonpayable"
    },
    {
        "type": "event",
        "name": "Initialized",
        "inputs": [
            {
                "name": "version",
                "type": "uint8",
                "indexed": false,
                "internalType": "uint8"
            }
        ],
        "anonymous": false
    },
    {
        "type": "event",
        "name": "PrepareRegistry",
        "inputs": [
            {
                "name": "dataId",
                "type": "bytes32",
                "indexed": false,
                "internalType": "bytes32"
            },
            {
                "name": "publicKeys",
                "type": "bytes[]",
                "indexed": false,
                "internalType": "bytes[]"
            }
        ],
        "anonymous": false
    },
    {
        "type": "event",
        "name": "Register",
        "inputs": [
            {
                "name": "",
                "type": "bytes32",
                "indexed": false,
                "internalType": "bytes32"
            }
        ],
        "anonymous": false
    }
]

module.exports={dataMgtAbi}