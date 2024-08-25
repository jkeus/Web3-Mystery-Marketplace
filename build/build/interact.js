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

personal.unlockAccount(eth.accounts[0], "aidan")


var contractAddress = "0xf6c119c941c958cd08036168b4684818b1293051"; 

var contractInstance = eth.contract(contractAbi).at(contractAddress);

// Call the greet function
contractInstance.greet(function(error, result) {
    if (!error) {
        console.log("Greeting:", result);
    } else {
        console.error("Error calling greet:", error);
    }
});

// Call the greeter function
var greetingMessage = "Hello from JavaScript"; // Example greeting message
contractInstance.greeter(greetingMessage, { from: eth.accounts[0] }, function(error, result) {
    if (!error) {
        console.log("Greeter function executed successfully");
    } else {
        console.error("Error calling greeter:", error);
    }
});

