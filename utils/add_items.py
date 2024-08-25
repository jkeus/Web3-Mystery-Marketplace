#! /usr/local/bin/python3.6

import sys
from web3 import Web3
from getpass import getpass  # Import getpass module to securely get password
import json

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))
with open('/home/aidan/abi.txt', 'r') as file:
    contract_abi = file.read()
contract_abi = json.loads(contract_abi)

# Convert the contract address to checksum format
contract_address = Web3.toChecksumAddress("0x15778323aF5E8830A9Db6b0eae3EDEA90f9DeF83")

contract_instance = w3.eth.contract(address=contract_address, abi=contract_abi)

# Unlock the account
account = w3.eth.accounts[0]
password = getpass("Enter the password to unlock the account: ")
w3.geth.personal.unlock_account(account, password)

# Call the greeter function
tx_hash = contract_instance.functions.setInventoryData(111, [1,2,3], [1,1,1], 1).transact({'from': account})

# Wait for the transaction to be mined
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

# Get the transaction receipt's status
if tx_receipt:
    print("Transaction Receipt:")
    print(tx_receipt)
    if tx_receipt.get("status") == 1:
        print("Function executed successfully")
    else:
        print("Error calling greeter:", tx_receipt.get("errorMessage"))
else:
    print("Transaction failed or not mined")

