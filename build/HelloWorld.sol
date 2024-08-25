pragma solidity ^ 0.4.25;
contract hello { /* define variable greeting of the type string */  
  string greeting;
  function greeter(string _greeting) public {
    greeting = _greeting;
  } 
  function greet() public constant returns(string) {
    return greeting;
  }
} 
