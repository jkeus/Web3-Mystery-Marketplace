#! /usr/local/bin/python3.6

from web3 import Web3
import json

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

with open('/home/aidan/utils/abi.txt', 'r') as file:
    contract_abi = json.load(file)

with open('/home/aidan/utils/bytecode.txt', 'r') as file:
    contract_bytecode = file.read().replace("\n", "")

# Convert the contract address to checksum format
from_address = w3.toChecksumAddress("0xc4b6c327518c1473b7509519b77f2907d9219c10")

# Unlock the account
unlock_result = w3.geth.personal.unlock_account(from_address, "aidan")

if unlock_result:
    print("Account unlocked successfully.")
else:
    print("Failed to unlock account. Aborting.")

# Deploy the contract
contract = w3.eth.contract(abi=contract_abi, bytecode=contract_bytecode)

# Construct constructor arguments
constructor_args = ("btc", "bitcoin")

# Estimate gas
gas_estimate = contract.constructor(*constructor_args).estimateGas()

# Deploy the contract
tx_hash = contract.constructor(*constructor_args).transact({'from': from_address, 'gas': gas_estimate})

# Wait for the transaction to be mined
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

print("Contract mined! Address:", tx_receipt.contractAddress)

