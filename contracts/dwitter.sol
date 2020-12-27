  // SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.10;
    library SafeMath {
    
        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow");
    
            return c;
        }
    
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            return sub(a, b, "SafeMath: subtraction overflow");
        }
    
        function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b <= a, errorMessage);
            uint256 c = a - b;
    
            return c;
        }
    
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0;
            }
    
            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");
    
            return c;
        }
    
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            return div(a, b, "SafeMath: division by zero");
        }
    
        function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b > 0, errorMessage);
            uint256 c = a / b;
            return c;
        }
    
    }

/// @title A Decentralised Social Media Platform
/// @author Mohit Bhat
/// @notice You can use this contract to connect to decentralised social network, share your content to the world
/// @dev Most of the features are implemented keeping note of security concerns
    contract Dwitter{
        using SafeMath for uint;
        address payable public owner;//Owner is also a maintainer
        bool public stopped = false;
        
        struct User{
            uint id;
            address ethAddress;
            string username;
            string name;
            string profileImgHash;
            string profileCoverImgHash;
            string bio;
            accountStatus status; // Account Banned or not
        }
        
        struct Dweet{
            uint dweetId;
            address author;
            string hashtag;
            string content;
            string imgHash;
            uint timestamp;
            uint likeCount;
            uint reportCount;
            cdStatus status; // Dweet Reported and Banned or not
        }
        
        struct Comment{
            uint commentId;
            address author;
            uint dweetId;
            string content;
            uint likeCount;
            // uint reportCount;
            uint timestamp;
            cdStatus status; // Comment Reported and Banned or not
        }
        
        uint public totalDweets=0;
        uint public totalComments=0;
        uint public totalUsers=0;
        
        ///@dev NP means not present the default value for status 
        enum accountStatus{NP,Active,Banned,Deactivated}
        enum cdStatus{NP,Active, Banned, Deleted}//Comment-Dweet status
        // enum dweetStatus{NP,Active, Banned, Deleted}
        
        mapping(address=>User) private users; //mapping to get user details from user address
        mapping(string=>address) private userAddressFromUsername;//to get user address from username
        // mapping(address=>bool) private registeredUser; //mapping to get user details from user address
        mapping(string=>bool) private usernames;//To check which username is taken taken=>true, not taken=>false

        
        mapping(uint=>Dweet) private dweets;// mapping to get dweet from Id
        mapping(address=>uint[]) private userDweets; // Array to store dweets(Id) done by user
        // mapping(uint=>address[]) private dweetLikersList;
        mapping(uint=>mapping(address=>bool)) private dweetLikers; // Mapping to track who liked which dweet
        
        mapping(uint=>Comment) private comments; //Mapping to get comment from comment Id
        mapping(address=>uint[]) private userComments;// Mapping to track user comments from there address
        // mapping(uint=>mapping(address=>bool)) private commentReporters; // Mapping to track who reported which comment
        // mapping(uint=>mapping(address=>bool)) private commentLikers; // Mapping to track who liked on which comment
        mapping(uint=>uint[]) private dweetComments; // Getting comments for a specific dweet
        
        modifier stopInEmergency { require(!stopped); _; }
        modifier onlyInEmergency { require(stopped); _; }
        
        modifier onlyOwner{require(msg.sender==owner); _;}
        modifier onlyDweetAuthor(uint id){require(msg.sender==dweets[id].author); _;}
        modifier onlyCommentAuthor(uint id){require(msg.sender==comments[id].author); _;}
        modifier onlyAllowedUser(address user){require(users[user].status==accountStatus.Active); _;}
        modifier onlyActiveDweet(uint id){require(dweets[id].status==cdStatus.Active); _;}
        modifier onlyActiveComment(uint id){require(comments[id].status==cdStatus.Active); _;}
        modifier usernameTaken(string memory username){require(!usernames[username]); _;}
     // modifier checkUserExists(){require(registeredUser[msg.sender]); _;}
        modifier checkUserNotExists(address user){require(users[user].status==accountStatus.NP); _;}

        
        event logRegisterUser(address user, uint id);
        event logUserBanned(address user, uint id);
        event logDweetCreated(address author, uint userid, uint dweetid, string hashtag);
        event logDweetDeleted(uint id, string hashtag);
        // event logCommentBanned(uint id, string hashtag);
        
        constructor() public {
            owner=msg.sender;
            isMaintainer[owner]=true;
        }
        
/*
**************************************USER FUNCTIONS***********************************************************
*/
        function usernameAvailable(string memory _username) public view returns(bool status){
            return !usernames[_username];
        }
        
        function registerUser(string memory _username, string memory _name, string memory _imgHash, string memory _coverHash, string memory _bio ) public checkUserNotExists(msg.sender) usernameTaken(_username){
            /// Reentrancy attack Prevented
            usernames[_username]=true;
            users[msg.sender]=User(++totalUsers, msg.sender, _username, _name, _imgHash, _coverHash, _bio, accountStatus.Active);
            userAddressFromUsername[_username]=msg.sender;
            emit logRegisterUser(msg.sender, totalUsers);
        }
        
        function userStatus() public view returns(accountStatus status){
            return users[msg.sender].status;
        }
        
        function changeUsername(string memory _username) public onlyAllowedUser(msg.sender) usernameTaken(_username){
            users[msg.sender].username=_username;
        }
        
        function getUser() public view returns(uint id, string memory username, string memory name, string memory imghash, string memory coverhash, string memory bio){
            return(users[msg.sender].id,users[msg.sender].username, users[msg.sender].name, users[msg.sender].profileImgHash, users[msg.sender].profileCoverImgHash, users[msg.sender].bio);
        }
        
        function getUser(address _user) public view returns(uint id, string memory username, string memory name, string memory imghash, string memory bio){
            return(users[_user].id,users[msg.sender].username, users[msg.sender].name, users[msg.sender].profileImgHash, users[msg.sender].bio);
        }
        
        function banUser(address _user) internal onlyAllowedUser(_user) {
            delete users[_user];
            users[_user].status=accountStatus.Banned;
            emit logUserBanned(msg.sender, users[_user].id);
        }

/*
**************************************DWEET FUNCTIONS***********************************************************
*/        
        function createDweet(string memory _hashtag, string memory _content, string memory _imghash) public onlyAllowedUser(msg.sender) {
            uint id=++totalDweets;
            dweets[id]=Dweet(id, msg.sender, _hashtag, _content, _imghash, block.timestamp , 0, 0, cdStatus.Active);
            userDweets[msg.sender].push(totalDweets);
            emit logDweetCreated(msg.sender, users[msg.sender].id, totalDweets, _hashtag);
        }
        
        function banDweet(uint _id) internal{
            emit logDweetBanned(_id, dweets[_id].hashtag, maintainerId[msg.sender]);
            delete dweets[_id];
            dweets[_id].status=cdStatus.Banned;
            for(uint i=0;i<dweetComments[_id].length;i++){
                delete dweetComments[_id][i];
            }
            delete dweetComments[_id];
        }
        
        function editDweet(uint _id, string memory _hashtag, string memory _content, string memory _imghash) public onlyActiveDweet(_id)
        onlyAllowedUser(msg.sender) onlyDweetAuthor(_id) {
            dweets[_id].hashtag=_hashtag;
            dweets[_id].content=_content;
            dweets[_id].imgHash=_imghash;
        }
        
        function deleteDweet(uint _id) public onlyActiveDweet(_id) onlyAllowedUser(msg.sender) onlyDweetAuthor(_id){
            emit logDweetDeleted(_id, dweets[_id].hashtag);
            delete dweets[_id];
            dweets[_id].status=cdStatus.Deleted;
            for(uint i=0;i<dweetComments[_id].length;i++){
                delete dweetComments[_id][i];
            }
            delete dweetComments[_id];
        }
        
        function getDweet(uint _id) public onlyAllowedUser(msg.sender) onlyActiveDweet(_id) view returns ( address author, string memory hashtag, string memory content, string memory imgHash, uint timestamp, uint likeCount ){
            return (dweets[_id].author, dweets[_id].hashtag, dweets[_id].content, dweets[_id].imgHash, dweets[_id].timestamp, dweets[_id].likeCount);
        }
        
        function likeDweet(uint _id) public onlyAllowedUser(msg.sender) onlyActiveDweet(_id){
            require(!dweetLikers[_id][msg.sender]);
            dweets[_id].likeCount++;
            dweetLikers[_id][msg.sender]=true;
        }
        
        function getUserDweets() public view onlyAllowedUser(msg.sender) returns(uint[] memory dweetList){
            return userDweets[msg.sender];
        }
        
        function getUserDweets(address _user) public view onlyAllowedUser(msg.sender) returns(uint[] memory dweetList){
            return userDweets[_user];
        }

/*
**************************************COMMENT FUNCTIONS***********************************************************
*/ 
        
        function createComment(uint _dweetid, string memory _comment) public onlyAllowedUser(msg.sender)  onlyActiveDweet(_dweetid){
            uint id=++totalComments;
            comments[id]=Comment(id, msg.sender, _dweetid, _comment, 0, block.timestamp, cdStatus.Active);
            userComments[msg.sender].push(totalComments);
            dweetComments[_dweetid].push(totalComments);
        }
        
        // function banComment(uint _id) internal {
        //     emit logCommentBanned(_id, dweets[comments[_id].dweetId].hashtag);
        //     delete comments[_id];
        //     comments[_id].status=cdStatus.Banned;
        // }
        
        function editComment(uint _commentid, string memory _comment) public onlyAllowedUser(msg.sender)  onlyActiveComment(_commentid) onlyCommentAuthor(_commentid){
            comments[_commentid].content=_comment;
        }
        
        function deleteComment(uint _id) public onlyActiveComment(_id) onlyAllowedUser(msg.sender) onlyCommentAuthor(_id) {
            delete comments[_id];
            comments[_id].status=cdStatus.Deleted;
        }
        
        function getComment(uint _id) public view onlyAllowedUser(msg.sender) onlyActiveComment(_id) returns(address author, uint dweetId, string memory content, uint likeCount, uint timestamp, cdStatus status){
            return(comments[_id].author, comments[_id].dweetId, comments[_id].content, comments[_id].likeCount, comments[_id].timestamp, comments[_id].status);
        }
        
        /// @dev Though onlyAllowedUser can be bypassed easily but still keeping for general audience 
        function getUserComments() public view onlyAllowedUser(msg.sender) returns(uint[] memory commentList){
            return userComments[msg.sender];
        }
        
        function getUserComments(address _user) public view onlyAllowedUser(msg.sender) returns(uint[] memory commentList){
            return userComments[_user];
        }
        
        function getDweetComments(uint _id) public view onlyAllowedUser(msg.sender) onlyActiveDweet(_id) returns(uint[] memory list){
            return(dweetComments[_id]);
        }
        
/*
**********************************Reporting And Maintanining*****************************************
*/
      uint public totalMaintainers=0;
      uint[] private dweetsReportedList;
      uint private noOfReportsRequired=1;
      uint public reportingstakePrice=1936458778290500;
      uint public reportingRewardPrice=3872917556581000;
      mapping(address=>bool) public isMaintainer;
      mapping(address=>uint) private maintainerId;
      mapping(uint=>mapping(address=>bool)) private dweetReporters; // Mapping to track who reported which dweet
      mapping(address=>uint[]) public userReportList;
      enum reportAction{NP, Banned, Free}
      mapping(uint=>reportAction) private actionOnDweet;
      mapping(address=>uint) private userRewards;
      mapping(address=>uint) private fakeReportingReward;
      
      function addMaintainer(address _user) public onlyOwner {
          isMaintainer[_user]=true;
          maintainerId[msg.sender]=++totalMaintainers;
      }
      
      function revokeMaintainer(address _user) public onlyOwner{
          isMaintainer[_user]=false;
      }
      
      modifier onlyMaintainer(){
          require(isMaintainer[msg.sender]);
          _;
      }
      
      modifier paidEnoughforReporter() { require(msg.value >= reportingstakePrice); _;}
        
      modifier checkValueforReporter() {
        _;
        uint amountToRefund = msg.value - reportingstakePrice;
        msg.sender.transfer(amountToRefund);
      }
      
      event logDweetReported(uint id, string hashtag);
      event logDweetBanned(uint id, string hashtag, uint maintainer); // To track how many dweets were banned to specific hashtag

      function reportDweet(uint _dweetId) public payable onlyActiveDweet(_dweetId) onlyAllowedUser(msg.sender) paidEnoughforReporter checkValueforReporter{
          require(dweets[_dweetId].reportCount<=noOfReportsRequired);
          require(!dweetReporters[_dweetId][msg.sender]);
          dweetReporters[_dweetId][msg.sender]=true;//Reentracy attack Prevented
          userReportList[msg.sender].push(_dweetId);
          uint reports=++dweets[_dweetId].reportCount;
          if(reports==noOfReportsRequired){
              dweetsReportedList.push(_dweetId);
              emit logDweetReported(_dweetId, dweets[_dweetId].hashtag);
          }
      }
      
      function takeAction(uint _dweetId, bool _action) public onlyMaintainer onlyActiveDweet(_dweetId) onlyAllowedUser(msg.sender){
          require(actionOnDweet[_dweetId]==reportAction.NP);
          if(_action){
              actionOnDweet[_dweetId]=reportAction.Banned;
              banDweet(_dweetId);
          }else{
              actionOnDweet[_dweetId]=reportAction.Free;
              fakeReportingReward[dweets[_dweetId].author]+=reportingstakePrice.mul(noOfReportsRequired);
          }
      }
      
      
      function claimReportingReward() public onlyAllowedUser(msg.sender){
          require(userReportList[msg.sender].length>0);
          for(uint i=userReportList[msg.sender].length-1;i>=0;i--){
              if(actionOnDweet[userReportList[msg.sender][i]]==reportAction.NP){
                  revert();
              }
              if(actionOnDweet[userReportList[msg.sender][i]]==reportAction.Banned){
                  userRewards[msg.sender]+=reportingRewardPrice;
                  delete(userReportList[msg.sender][i]);
              }
              if(actionOnDweet[userReportList[msg.sender][i]]==reportAction.Free){
                  delete(userReportList[msg.sender][i]);
              }
          }
          
          delete(userReportList[msg.sender]);
          msg.sender.transfer(userRewards[msg.sender]);
      }
      
      function getReportedDweets() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
          return(dweetsReportedList);
      }
      
      function getReportedDweetStatus(uint _dweetId) public view onlyAllowedUser(msg.sender) returns(reportAction status){
          return(actionOnDweet[_dweetId]);
      }
      
      
/*
*******************************************Advertisement **************************************************************
*/
      uint public advertisementCost=96822938914524992;
      uint public totalAdvertisements=0;
      
      enum AdApprovalStatus{NP, Approved, Rejected}
      
      struct Advertisement{
        uint id;
        address advertiser;
        string imgHash;
        string link;
        AdApprovalStatus status;
        uint expiry;
      }
      
      modifier paidEnoughforAdvertisement() { require(msg.value >= advertisementCost); _;}
        
      modifier checkValueforAdvertisement() {
        _;
        uint amountToRefund = msg.value - advertisementCost;
        msg.sender.transfer(amountToRefund);
      }
      
      mapping(address=>uint[]) public advertiserAdvertisementsList;
      mapping(uint=>Advertisement) private advertisements;
      uint[] private advertisementsList;
      
      function submitAdvertisement(string memory _imgHash, string memory _link) public payable onlyAllowedUser(msg.sender) paidEnoughforAdvertisement checkValueforAdvertisement{
          uint id=++totalAdvertisements;
          advertisements[id]=Advertisement(id, msg.sender, _imgHash, _link, AdApprovalStatus.NP, 0);
          advertisementsList.push(id);
          advertiserAdvertisementsList[msg.sender].push(id);
      }
      
      function advertisementApproval(uint _id, bool _decision) public onlyMaintainer{
          require(advertisements[_id].status==AdApprovalStatus.NP);
          if(_decision){
              advertisements[_id].status=AdApprovalStatus.Approved;
              advertisements[_id].expiry=block.timestamp+ 1 days;
          }else{
              advertisements[_id].status=AdApprovalStatus.Rejected;
              uint refund=advertisementCost.mul(8).div(100);
              msg.sender.transfer(refund);
          }
      }
      
      function getAds() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
          return(advertisementsList);
      }
      
      function getAd(uint _id) public view onlyAllowedUser(msg.sender) returns(address advertiser, string memory imgHash, string memory link, AdApprovalStatus status, uint expiry){
          return(advertisements[_id].advertiser, advertisements[_id].imgHash, advertisements[_id].link, advertisements[_id].status, advertisements[_id].expiry);
      }
      
      function myAdvertisements() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
          return(advertiserAdvertisementsList[msg.sender]);
      }
      
      function getAdvertisementStatus(uint _id) public view onlyAllowedUser(msg.sender) returns(AdApprovalStatus status){
          return advertisements[_id].status;
      }
      
      function getBalance()public view onlyOwner() returns(uint balance){
          return address(this).balance;
      }
      
        
    }