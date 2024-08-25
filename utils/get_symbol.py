#! /usr/local/bin/python3.6

from web3 import Web3
import json

contract_address_raw = "0xbC0480E8C9F72973978b22d0AfCc37Fc453a36EC"

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

with open('/home/aidan/utils/abi.txt', 'r') as file:
    contract_abi = file.read()
contract_abi = json.loads(contract_abi)

with open('/home/aidan/utils/bytecode.txt', 'r') as file:
    contract_bytecode = file.read()
contract_bytecode = contract_bytecode.replace("\n", "")

# Convert the contract address to checksum format
contract_address = Web3.toChecksumAddress(contract_address_raw)

contract = w3.eth.contract(address=contract_address, abi=contract_abi, bytecode=contract_bytecode)

# Call the greet function
#account_address = Web3.toChecksumAddress("0xc4b6c327518c1473b7509519b77f2907d9219c10")
#greeting = contract.functions.balanceOf(account_address).call()
greeting = contract.functions.symbol().call()
print("returns:", greeting)

