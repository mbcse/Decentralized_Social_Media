# Decentralized Social Media(Dwitter)
`Consensys Bootcamp Project`

## Introduction

In the present world social media has become a very important part of our lives. We share so much content everyday ranging from what we are doing in our personal lives to professional information. For some it's a source of income due to its marketing capabilties and for some it's platform to share there content, for some its a platform to raise there voice and for some it's a platform to connect to world. Infact some social media platforms have become a political playground also. Many decisions, ideas, events our shared on these platforms, consider the case of twitter many heads of countries share updates on this platform. But with all these things we know social media has a problem due to its centralized nature. we have seen of password leak of twitter users and forcefull banning of accounts due to political influence. Also the advertisers may not know wether the ads they are promoting are not influenced by these companies. All these things force us to adopt a decentralization and this project have tried to implemented that.


## Platform Overview

The platform is a decentralized social media something similar to twitter but totally in a decentralized way having no server. The platform is having a smart contract containing all the important logic and is deployed on Ethereum Blockchain. Some of the features of the platform are:
- Secure and user friendly login using metamask wallet
- Only your Public address is the key to access the platform
- Cool user profile same as Twitter
- Easy to use interface
- Commenting feature on dweets
- Reporting feature on dweets
  - Once a dweet get a specified no of reports it will be sent to maintainers for action
  - You will have to stake some ethers for reporting
  - If the dweet is banned by maintainers you will get refund and a reward
  - If the dweet is not Banned by maintainers you will get no refund and the staked amount will go to the reported dweet author
- Like feature on dweets
- You can upload advertisements(image and a link) and reach out to platform users at nominal cost
  - Advertisements once submitted will be sent to maintainers for acceptance
  -If it is rejected then 80% amount will be refunded
- Maintainers can be added to the platform
- A dedicated maintainer page where you can give acceptance and ban dweets(**only If it gets required reports**)

## Tech stack Used
- Ethereum
- IPFS
- Web3js
- HTML
- CSS
- Bootstrap
- Javascript
- Jquery
- Truffle

## Future Work
- Use Meta transactions(gasless transactions) to make the platform gas free for users
- Add more Features like follow, profile view etc
- Add video Advertisement options
- Add reporting on comments


## Directory Structure
```
📦 DECENTRALIZED_SOCIAL_MEDIA
 ┣ 📂 .github
 ┣ 📂 node_modules
 ┣ 📂 build (Recent build of the Smart Contracts)
 ┣ 📂 contract (Solidity Smart Contracts)
 ┣ 📂 migrations (Truffle deployment migrations)
 ┣ 📂 test (Smart Contract Tests)
 ┣ 📂 src (Dapp Frontend)
 ┣ 📜 avoiding_common_attacks.md
 ┣ 📜 design_pattern_decisions.md
 ┣ 📜 package.json (project dependencies)
 ┣ 📜 README.md (Project Documentation)
 ┣ 📜 server.js (Lite server to host frontend)
 ┗ 📜 truffle-config.js (Truffle Project Config)
```

## Running the project

### Smart Contracts
1. Run `npm i` to install dependencies.
4. Run `ganache-cli` to start a local chain.
3. In the projects root directory, run `truffle console` to interact with the porject.
4. To compile contracts run `truffle compile`
5. To deploy run `truffle migrate` 
6. To test run `truffle test` 

### Frontend/To Start Local Server
1. In the projects root directory, run `npm start`

## Project Demo
Website 👉 [https://dwittermedia.herokuapp.com/](https://dwittermedia.herokuapp.com/)

YouTube 👉 [https://youtu.be/l75vF8HAJ8Y](https://youtu.be/l75vF8HAJ8Y)

## Avoiding Common Attacks
Documented here 👉 [avoiding_common_attacks.md](avoiding_common_attacks.md)

## Deployed Addresses
Documented here 👉 [deployed_addresses.md](deployed_addresses.md)

## Design Pattern Decisions
Documented here 👉 [design_pattern_decisions.md](design_pattern_decisions.md)
