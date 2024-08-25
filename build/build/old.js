var Web3 = require('web3');
var web3 = new Web3('http://localhost:8545'); // Replace with your Ethereum node URL

var contractAbi = [
    {
        "constant": true,
        "inputs": [],
        "name": "greet",
        "outputs": [
            {
                "name": "",
                "type": "string"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "_greeting",
                "type": "string"
            }
        ],
        "name": "greeter",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

var contractAddress = "0x03f2dd6bedeb041511429b9591ea691cac8116df"; // Replace with your contract address
var contract = new web3.eth.Contract(contractAbi, contractAddress);

var newGreeting = "cats";

// Send a transaction to the greeter function to set the new greeting
contract.methods.greeter(newGreeting).send({
    from: '0xYourSenderAddress', // Replace with the sender address
    gas: 200000, // Adjust gas limit as needed
})
.then(function(receipt){
    console.log("Transaction Receipt:", receipt);
})
.catch(function(error){
    console.error("Error executing greeter function:", error);
});

