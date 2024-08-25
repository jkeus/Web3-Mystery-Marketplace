#! /usr/local/bin/python3.6

import sys
from web3 import Web3
from getpass import getpass 
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


token_id = contract_instance.functions.tokenOfOwnerByIndex(account, 0).call()

print("Token ID at index:", token_id)

