#! /usr/local/bin/python3.6

import sys
from web3 import Web3
from getpass import getpass  # Import getpass module to securely get password
import json
import os
import cgi


print("Content-Type: text/html")
print("")

query_string = os.environ.get('QUERY_STRING')

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

parsed_query = cgi.parse_qs(query_string)
password = parsed_query.get('password', [''])[0]
account = parsed_query.get('account', [''])[0]
account = account.strip()
if not w3.isChecksumAddress(account):
    account = w3.toChecksumAddress(account)

with open('/var/www/html/abi.txt', 'r') as file:
    contract_abi = file.read()
contract_abi = json.loads(contract_abi)

contract_address = Web3.toChecksumAddress("0xedbd00ECc07f96e4A734BC5D46942F24C485b589")

contract_instance = w3.eth.contract(address=contract_address, abi=contract_abi)

# Unlock the account
w3.geth.personal.unlock_account(account, password)

token_id = contract_instance.functions.viewAllListings().call()

print(token_id)
