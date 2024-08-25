# File Descriptions

## ./contract.sol
- source code of our smart contract

## ./abi.txt & ./bytecode.txt
- Text files that hold the output of the Remix compiler
- Referenced by Python scripts to deploy the smart contract and abi.txt needed call smart contract functions 

## ./html
 - stores our website interface
 - incudes the Javascript, HTML, css
 - also includes the executable python scripts that Apache web server executes

## ./utils 
- includes Python scripts used for bebugging (not used by Apache)
- `./utils/deploy.py*` is used to deploy contracts to our private Geth network
- `./utils/deploy_using_js.js` does the same thing using javascript+web3 instead of Python+web3 (not by us used anymore)
- `./utils/abi.txt1` and `./utils/bytecode.txt` holds the output of the Remix compiler
- other python scripts used for debugging to manually call smart contract functions

## ./lab1
- includes the files needed to deploy our private Geth network (very similar to Lab1)
- `./lab1/launch.sh` modified to allow more API access for Python Web3 scripts 

# Reproduce Demo Instructions

## Environment (Ubuntu + Geth)
- Ubuntu 22.04 x86_64
- Geth binary and genesis.json files reused from Lab 1
- Launch Geth with `./lab1/launch.sh` which contains: `geth --datadir bkc_data --rpcapi personal,eth --http --networkid 89992018 --allow-insecure-unlock --http.corsdomain "*" console  2>console.log`
- Follow the same steps from Lab 1 to use the Geth javascript console to create accounts and then run `> miner.start(1)`


## Web Server
- `sudo apt update && sudo apt install apache2`
- `sudo a2enmod cgid`
- add the following to `/etc/apache2/apache2.conf`
  ```
  <Directory "/var/www/html">
        Options +ExecCGI
        AddHandler cgi-script .py
  </Directory>
  ```
- `sudo systemctl restart apache2`
- copy the contents of `./html` into `/var/www/html` so Apache can find our website source code
  
## Using it!
- Open 'localhost' or 'localhost:80' in any web browser to access and use the web interface which will connect to and modify the Geth network.
