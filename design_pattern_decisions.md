# Design Patterns

## Fail early and fail loud
I have used `require()` at all the places to stop a user from executing the function at very start if he don't have the required permissions or if something was failing
## Restricting Access
Have used modifers like onlyOwner(), onlyAuthor(), onlyMaintainer() etc with require statements to restrict unauthorised access on the functions
## Circuit Breaker
Have used stop and start functions for dapp that can be executed only by owner to stop dapp from executing in case of emergency or Maintainance;
## Ownership pattern
The contract while deploying has its constructor called and in that constructor the owner of the contract is specified. An owner can also update/change the ownership to a new address.