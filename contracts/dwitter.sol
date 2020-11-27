// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.10;

/// @title A Decentralised Social Media Platform
/// @author Mohit Bhat
/// @notice You can use this contract to connect to decentralised social network, share your content to the world
/// @dev Most of the features are implemented keeping note of security concerns
    contract Dwitter{
        
        address payable public owner;//Owner is also a maintainer
        address[] public maintainers;
        bool public stopped = false;
        
        struct User{
            uint id;
            address ethAddress;
            string username;
            string name;
            string profileImgHash;
            string bio;
            bool active; // Account Banned or not
        }
        
        struct Dweet{
            uint dweetId;
            string title;
            string content;
            string imgHash;
            string author;
            uint likeCount;
            bool active; // Dweet Reported and Banned or not
        }
        
        struct Comment{
            uint dweetId;
            uint commentId;
            string content;
            address author;
            uint likeCount;
            bool active; // Comment Reported and Banned or not
        }
        
        uint public totalDweets=0;
        uint public totalComments=0;
        uint public totalUsers=0;
        
        mapping(address=>User) private users; //mapping to get user details from user address
        mapping(string=>address) private userAddressFromUsername;//to get user address from username
        mapping(address=>bool) private registeredUser; //mapping to get user details from user address
        mapping(string=>bool) private usernames;//To check which username is taken taken=>true, not taken=>false

        
        mapping(uint=>Dweet) private dweets;// mapping to get dweet from Id
        mapping(address=>uint[]) private userDweets; // Array to store dweets(Id) done by user
        mapping(uint=>mapping(address=>bool)) private dweetReporters; // Mapping to track who reported which dweet
        mapping(uint=>mapping(address=>bool)) private dweetLikers; // Mapping to track who liked which dweet
        
        mapping(uint=>Comment) private comments; //Mapping to get comment from comment Id
        mapping(address=>uint[]) private userComments;// Mapping to track user comments
        mapping(uint=>mapping(address=>bool)) private commentReporters; // Mapping to track who reported which comment
        mapping(uint=>mapping(address=>bool)) private commentLikers; // Mapping to track who liked on which comment
        
        mapping(address=>bool) private maintainer;//Mapping to check weather a address is maintainer or not
        
       
        
        modifier stopInEmergency { require(!stopped); _; }
        modifier onlyInEmergency { require(stopped); _; }
        
        modifier onlyOwner{require(msg.sender==owner); _;}
        modifier onlyAuthor(address author){require(msg.sender==author); _;}
        modifier onlyMaintainers{require(maintainer[msg.sender]); _;}
        modifier onlyAllowedUser{require(registeredUser[msg.sender] && users[msg.sender].active); _;}
        modifier onlyActiveDweet(uint id){require(dweets[id].active); _;}
        modifier onlyActiveComment(uint id){require(comments[id].active); _;}
        modifier checkUsername(string memory username){require(!usernames[username]); _;}
        // modifier checkUserExists(){require(registeredUser[msg.sender]); _;}
        modifier checkUserNotExists(){require(!registeredUser[msg.sender]); _;}

        
        event logRegisterUser(address _ethAddress, string _username, string _name);
        
        
        constructor() public{
            owner=msg.sender;
            maintainer[msg.sender]=true;
        }
        
        
        function usernameAvailable(string memory _username) public view returns(bool status){
            return usernames[_username];
        }
        
        function registerUser(string memory _username, string memory _name, string memory _imgHash, string memory _bio ) public checkUserNotExists checkUsername(_username){
            users[msg.sender]=User(++totalUsers, msg.sender, _username, _name, _imgHash, _bio, true);
            userAddressFromUsername[_username]=msg.sender;
            emit logRegisterUser(msg.sender, _username, _name);
        }
        
        function changeUsername(string memory _username) public onlyAllowedUser checkUsername(_username){
            users[msg.sender].username=_username;
        }

        
        
        
        
        
        
        
        
        
    }