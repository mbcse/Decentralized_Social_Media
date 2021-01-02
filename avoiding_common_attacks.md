# Common Attacks Avoided

## Re-entracy Attacks
- Race Conditions: Have used `.send()` instead of `.call.value()`
- Cross function: Have not used any two functions which are changing same state
Also in all the functions the state is updated first and then funds are transfered to prevent a reentracy attack. This has been taken care in reporting, like, claimreward etc functions.

## Integer Overflow and Underflow
Have used Safemath library to prevent integer overflow and underflow. This was required while calculating time, The amount user is sending etc.

## Denial of Service with Failed Call
No for loop is there to send funds to a set of users, although this was needed while sending rewards for the reported dweets by a user but instead of that i have made the logic in a way such that the user will ask for reward for a particular reported dweet. So this prevents a Failed call/DOS attack.

## Denial of Service by Block Gas Limit or startGas
There is no unknown size loop in the contract, although it was needed while transfering rewards but that logic has been broken down and now user will ask for a particular reward

## Timestamp Dependence
Though timestamp dependence is there but it does not cause any major security issue in the dapp.