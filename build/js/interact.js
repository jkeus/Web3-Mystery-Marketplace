var contractAbi = [{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":true,"inputs":[],"name":"getGreeting","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"greeting","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"_greeting","type":"string"}],"name":"setGreeting","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}];

//personal.unlockAccount(eth.accounts[0], "aidan")
var contractAddress = "0x32c643a7d7535361aa4f9e2e6942380b4d5739f2";
var contract = web3.eth.contract(contractAbi).at(contractAddress);


contract.getGreeting(function(error, result) {
    if (!error) {
        console.log("Greeting:", result);
    } else {
        console.error("My Error:", error);
    }
});

//loadScript("/home/aidan/build/build/interact.js");
// output should be shown
