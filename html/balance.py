#! /usr/local/bin/python3.6

import sys
from web3 import Web3
from getpass import getpass
import json
import os
import cgi


print("Content-Type: text/html")
print("")

query_string = os.environ.get('QUERY_STRING')

parsed_query = cgi.parse_qs(query_string)
account = parsed_query.get('account', [''])[0]

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

# Unlock the account
#account = w3.eth.accounts[0]
#password = "aidan"
#w3.geth.personal.unlock_account(account, password)

if not w3.isAddress(account):
    print("Not Logged In")
    sys.exit(1)

account = account.strip()
if not w3.isChecksumAddress(account):
    account = w3.toChecksumAddress(account)

balance_wei = w3.eth.get_balance(account)
balance_eth = w3.fromWei(balance_wei, 'ether')

print("Logged In:")
print("Wallet:  " + account)
print("Current Balance:  ", balance_eth, " Ether")
