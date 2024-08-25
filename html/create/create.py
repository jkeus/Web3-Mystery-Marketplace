#! /usr/local/bin/python3.6

import sys
from web3 import Web3
from getpass import getpass
import json
import os
import cgi

print("Content-Type: text/html")
print()

query_string = os.environ.get('QUERY_STRING')

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

parsed_query = cgi.parse_qs(query_string)
a = parsed_query.get('items', [''])[0]
b =  parsed_query.get('stock', [''])[0]
c =  parsed_query.get('price', [''])[0]
d = parsed_query.get('listing_id', [''])[0]
password = parsed_query.get('password', [''])[0]
account = parsed_query.get('account', [''])[0]
account = account.strip()
if not w3.isChecksumAddress(account):
    account = w3.toChecksumAddress(account)


item_ids = list(map(int, a.split(',')))
stock = list(map(int, b.split(','))) 
price = int(c)  
listing_id = int(d) 


with open('/var/www/html/abi.txt', 'r') as file:
    contract_abi = file.read()
contract_abi = json.loads(contract_abi)

contract_address = Web3.toChecksumAddress("0xedbd00ECc07f96e4A734BC5D46942F24C485b589")
contract_instance = w3.eth.contract(address=contract_address, abi=contract_abi)

# Unlock the account
#account = w3.eth.accounts[0]
#password = "aidan"
w3.geth.personal.unlock_account(account, password)

tx_hash = contract_instance.functions.setInventoryData(listing_id, item_ids, stock, price).transact({'from': account})
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

if tx_receipt:
    print("You succesffuly created a listing!");
    print("")
    print("Transaction Receipt:")
    print("")
    print(tx_receipt)
else:
    print("Transaction failed or not mined")

