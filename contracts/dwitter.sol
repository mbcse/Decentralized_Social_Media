/*
_____           _ _   _            
 |  __ \         (_) | | |           
 | |  | |_      ___| |_| |_ ___ _ __ 
 | |  | \ \ /\ / / | __| __/ _ \ '__|
 | |__| |\ V  V /| | |_| ||  __/ |   
 |_____/  \_/\_/ |_|\__|\__\___|_|   
                                     
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;
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
/// @notice You can use this contract to connect to decentralised social network, share your content to the world in a decentralised way!
/// @dev Most of the features are implemented keeping note of security concerns

contract Dwitter{
    using SafeMath for uint;
    address payable public owner; //Owner is also a maintainer
    bool public stopped = false;
    
    struct User{
        uint id;
        address ethAddress;
        string username;
        string name;
        string profileImgHash;
        string profileCoverImgHash;
        string bio;
        accountStatus status; // Account Banned or Not
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
        cdStatus status; // Dweet Active-Deleted-Banned
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
    
    modifier stopInEmergency { require(!stopped,"Dapp has been stopped!"); _; }
    modifier onlyInEmergency { require(stopped); _; }
    
    modifier onlyOwner{require(msg.sender==owner,"You are not owner!"); _;}
    modifier onlyDweetAuthor(uint id){require(msg.sender==dweets[id].author,"You are not Author!"); _;}
    modifier onlyCommentAuthor(uint id){require(msg.sender==comments[id].author,"You are not Author!"); _;}
    modifier onlyAllowedUser(address user){require(users[user].status==accountStatus.Active,"Not a Registered User!"); _;}
    modifier onlyActiveDweet(uint id){require(dweets[id].status==cdStatus.Active,"Not a active dweet"); _;}
    modifier onlyActiveComment(uint id){require(comments[id].status==cdStatus.Active,"Not a active comment"); _;}
    modifier usernameTaken(string memory username){require(!usernames[username],"Username already taken"); _;}
 // modifier checkUserExists(){require(registeredUser[msg.sender]); _;}
    modifier checkUserNotExists(address user){require(users[user].status==accountStatus.NP,"User already registered"); _;}

    
    event logRegisterUser(address user, uint id);
    event logUserBanned(address user, uint id);
    event logDweetCreated(address author, uint userid, uint dweetid, string hashtag);
    event logDweetDeleted(uint id, string hashtag);
    // event logCommentBanned(uint id, string hashtag);
    
    constructor() {
        owner=msg.sender;
        addMaintainer(msg.sender);
        registerUser("owner","owner","","","owner");
    }
    
    fallback() external{
        revert();
    }
        
/*
**************************************USER FUNCTIONS********************************************************************************
*/

    /// @notice Check username available or not
    /// @param  _username username to Check
    /// @return status true or false
    function usernameAvailable(string memory _username) public view returns(bool status){
        return !usernames[_username];
    }
    
    /// @notice Register a new user
    /// @param  _username username of username
    /// @param _name name of person
    /// @param _imgHash Ipfs Hash of users Profile Image
    /// @param _coverHash Ipfs Hash of user cover Image
    /// @param _bio Biography of user
    function registerUser(string memory _username, string memory _name, string memory _imgHash, string memory _coverHash, string memory _bio ) public stopInEmergency checkUserNotExists(msg.sender) usernameTaken(_username){
        usernames[_username]=true;// Attack Prevented
        totalUsers=totalUsers.add(1);
        uint id=totalUsers;
        users[msg.sender]=User(id, msg.sender, _username, _name, _imgHash, _coverHash, _bio, accountStatus.Active);
        userAddressFromUsername[_username]=msg.sender;
        emit logRegisterUser(msg.sender, totalUsers);
    }
    
    /// @notice Check accountStatus of user-Registered, Banned or Deleted
    /// @return status NP, Active, Banned or Deleted
    function userStatus() public view returns(accountStatus status){
        return users[msg.sender].status;
    }
    
    /// @notice Change username of a user
    /// @param _username New username of user
    function changeUsername(string memory _username) public stopInEmergency onlyAllowedUser(msg.sender) usernameTaken(_username){
        users[msg.sender].username=_username;
    }
    
    /// @notice Get user details
    /// @return id Id of user
    /// @return username username of person
    /// @return name Name of user
    /// @return imghash user profile image ipfs hash
    /// @return coverhash usercCover image ipfs hash
    /// @return bio Biography of user
    function getUser() public view returns(uint id, string memory username, string memory name, string memory imghash, string memory coverhash, string memory bio){
        return(users[msg.sender].id,users[msg.sender].username, users[msg.sender].name, users[msg.sender].profileImgHash, users[msg.sender].profileCoverImgHash, users[msg.sender].bio);
    }
    
    /// @notice Get user details
    /// @param _user address of user
    /// @return id Id of user
    /// @return username username of person
    /// @return name Name of user
    /// @return imghash user profile image ipfs hash
    /// @return coverhash usercCover image ipfs hash
    /// @return bio Biography of user
    function getUser(address _user) public view returns(uint id, string memory username, string memory name, string memory imghash, string memory coverhash, string memory bio){
        return(users[_user].id,users[_user].username, users[_user].name, users[_user].profileImgHash, users[_user].profileCoverImgHash, users[_user].bio);
    }
    
    /// @notice Ban user Internal Function
    /// @param  _user address of user
    function banUser(address _user) internal onlyAllowedUser(_user) onlyMaintainer {
        delete users[_user];
        users[_user].status=accountStatus.Banned;
        emit logUserBanned(msg.sender, users[_user].id);
    }

/*
**************************************DWEET FUNCTIONS***********************************************************
*/      
    /// @notice Create a new dweet
    /// @param _hashtag hashtag of dweet ex. #ethereum
    /// @param _content content of dweet to show
    /// @param _imghash Image type content ipfs hash
    function createDweet(string memory _hashtag, string memory _content, string memory _imghash) public stopInEmergency onlyAllowedUser(msg.sender) {
        totalDweets=totalDweets.add(1);
        uint id=totalDweets;
        dweets[id]=Dweet(id, msg.sender, _hashtag, _content, _imghash, block.timestamp , 0, 0, cdStatus.Active);
        userDweets[msg.sender].push(totalDweets);
        emit logDweetCreated(msg.sender, users[msg.sender].id, totalDweets, _hashtag);
    }
    
    /// @notice Ban Dweet Internal Function
    /// @param  _id Id of dweet
    function banDweet(uint _id) internal{
        emit logDweetBanned(_id, dweets[_id].hashtag, maintainerId[msg.sender]);
        delete dweets[_id];
        dweets[_id].status=cdStatus.Banned;
        for(uint i=0;i<dweetComments[_id].length;i++){
            delete dweetComments[_id][i];
        }
        delete dweetComments[_id];
    }
    
    /// @notice Edit a dweet 
    /// @param  _id Id of dweet
    /// @param  _hashtag New tag of dweet
    /// @param  _content New content of dweet
    /// @param  _imghash Hash of new image content
    function editDweet(uint _id, string memory _hashtag, string memory _content, string memory _imghash) public stopInEmergency onlyActiveDweet(_id)
    onlyAllowedUser(msg.sender) onlyDweetAuthor(_id) {
        dweets[_id].hashtag=_hashtag;
        dweets[_id].content=_content;
        dweets[_id].imgHash=_imghash;
    }
    
    /// @notice Delete a dweet
    /// @param  _id Id of dweet
    function deleteDweet(uint _id) public onlyActiveDweet(_id) onlyAllowedUser(msg.sender) stopInEmergency onlyDweetAuthor(_id){
        emit logDweetDeleted(_id, dweets[_id].hashtag);
        delete dweets[_id];
        dweets[_id].status=cdStatus.Deleted;
        for(uint i=0;i<dweetComments[_id].length;i++){
            delete dweetComments[_id][i];
        }
        delete dweetComments[_id];
    }
    
    /// @notice Get a Dweet
    /// @param  _id Id of dweet
    /// @return author Dweet author address 
    /// @return  hashtag Tag of dweet
    /// @return  content Content of dweet
    /// @return  imgHash Hash of image content
    /// @return  timestamp Dweet creation timestamp
    /// @return  likeCount No of likes on dweet
    function getDweet(uint _id) public onlyAllowedUser(msg.sender) onlyActiveDweet(_id) view returns ( address author, string memory hashtag, string memory content, string memory imgHash, uint timestamp, uint likeCount ){
        return (dweets[_id].author, dweets[_id].hashtag, dweets[_id].content, dweets[_id].imgHash, dweets[_id].timestamp, dweets[_id].likeCount);
    }
    
    /// @notice Like a dweets
    /// @param _id Id of dweet to be likeDweet
    function likeDweet(uint _id) public onlyAllowedUser(msg.sender) onlyActiveDweet(_id){
        require(!dweetLikers[_id][msg.sender]);
        dweets[_id].likeCount=dweets[_id].likeCount.add(1);
        dweetLikers[_id][msg.sender]=true;
    }
    
    /// @notice Get list of dweets done by a user
    /// @return dweetList Array of dweet ids
    function getUserDweets() public view onlyAllowedUser(msg.sender) returns(uint[] memory dweetList){
        return userDweets[msg.sender];
    }
    
    /// @notice Get list of dweets done by a user
    /// @param _user User address
    /// @return dweetList Array of dweet ids
    function getUserDweets(address _user) public view onlyAllowedUser(msg.sender) returns(uint[] memory dweetList){
        return userDweets[_user];
    }

/*
**************************************COMMENT FUNCTIONS*************************************************************************
*/ 
    /// @notice Create a comment on dweet
    /// @param  _dweetid Id of dweetList
    /// @param  _comment content of comment
    function createComment(uint _dweetid, string memory _comment) public stopInEmergency onlyAllowedUser(msg.sender)  onlyActiveDweet(_dweetid){
        totalComments=totalComments.add(1);
        uint id=totalComments;
        comments[id]=Comment(id, msg.sender, _dweetid, _comment, 0, block.timestamp, cdStatus.Active);
        userComments[msg.sender].push(totalComments);
        dweetComments[_dweetid].push(totalComments);
    }
    
    // function banComment(uint _id) internal {
    //     emit logCommentBanned(_id, dweets[comments[_id].dweetId].hashtag);
    //     delete comments[_id];
    //     comments[_id].status=cdStatus.Banned;
    // }
    
    
    /// @notice Get list of dweets done by a user
    /// @param  _commentid Id of comments
    /// @param  _comment New content of comment
    function editComment(uint _commentid, string memory _comment) public stopInEmergency onlyAllowedUser(msg.sender)  onlyActiveComment(_commentid) onlyCommentAuthor(_commentid){
        comments[_commentid].content=_comment;
    }
    
    /// @notice Delete a comment
    /// @param _id Id of comment to be Deleted
    function deleteComment(uint _id) public stopInEmergency onlyActiveComment(_id) onlyAllowedUser(msg.sender) onlyCommentAuthor(_id) {
        delete comments[_id];
        comments[_id].status=cdStatus.Deleted;
    }
    
    /// @notice Get a comment
    /// @param  _id Id of comment
    /// @return author Address of author
    /// @return dweetId Id of dweet 
    /// @return content content of comment
    /// @return likeCount Likes on commment
    /// @return timestamp Comment creation timestamp
    /// @return status status of Comment active-banned-deleted
    function getComment(uint _id) public view onlyAllowedUser(msg.sender) onlyActiveComment(_id) returns(address author, uint dweetId, string memory content, uint likeCount, uint timestamp, cdStatus status){
        return(comments[_id].author, comments[_id].dweetId, comments[_id].content, comments[_id].likeCount, comments[_id].timestamp, comments[_id].status);
    }
    
    /// @notice Get comments done by user
    /// @return commentList Array of comment ids
    /// @dev Though onlyAllowedUser can be bypassed easily but still keeping for calls from frontend 
    function getUserComments() public view onlyAllowedUser(msg.sender) returns(uint[] memory commentList){
        return userComments[msg.sender];
    }
    
    /// @notice Get comments done by user
    /// @param _user address of user
    /// @return commentList Array of comment ids
    function getUserComments(address _user) public view onlyAllowedUser(msg.sender) returns(uint[] memory commentList){
        return userComments[_user];
    }
    
    /// @notice Get comments on a dweet
    /// @return list Array of comment ids
    function getDweetComments(uint _id) public view onlyAllowedUser(msg.sender) onlyActiveDweet(_id) returns(uint[] memory list){
        return(dweetComments[_id]);
    }
        
/*
**********************************Reporting And Maintanining*****************************************************************************************
*/
    uint public totalMaintainers=0;
    uint[] private dweetsReportedList;// List of ids of reported dweets
    uint private noOfReportsRequired=1;// No of reports required to term a dweet reported and send for action
    uint public reportingstakePrice=1936458778290500;// Stake amount to pay while reporting
    uint public reportingRewardPrice=3872917556581000;// Reward of correct reporting
      
    mapping(address=>bool) public isMaintainer;
    mapping(address=>uint) private maintainerId;
    mapping(uint=>mapping(address=>bool)) private dweetReporters; // Mapping to track who reported which dweet
    mapping(uint=>reportAction) private actionOnDweet;// What is the ction on dweet done by maintainers
    mapping(address=>uint[]) public userReportList;// Ids of dweets reported by a user
    //mapping(address=>uint) private userRewards;
    mapping(address=>uint) private fakeReportingReward;// Reward a user get when somebody do a fake reporting against that user
    mapping(uint=>mapping(address=>userdweetReportingStatus)) private claimedReward;//To check whether user has claimed reward for a particular reporting
      
    enum userdweetReportingStatus{NP, Reported, Claimed}
    enum reportAction{NP, Banned, Free}
    
    modifier onlyMaintainer(){
        require(isMaintainer[msg.sender],"You are not a maintainer");
        _;
    }
    
    modifier paidEnoughforReporter() { require(msg.value >= reportingstakePrice,"You have not paid enough for advertisement"); _;}
        
    modifier checkValueforReporter() {
        _;
        uint amountToRefund = msg.value.sub(reportingstakePrice);
        msg.sender.transfer(amountToRefund);
    }
      
    /// @notice Add a maintainer to the platform
    /// @param _user Address of user to be added as maintainer
    function addMaintainer(address _user) public onlyOwner {
        isMaintainer[_user]=true;
        totalMaintainers=totalMaintainers.add(1);
        maintainerId[msg.sender]=totalMaintainers;
    }
     
    /// @notice Remove a maintainer 
    /// @param _user Address of user to be removed from maintainer  
    function revokeMaintainer(address _user) public onlyOwner{
        isMaintainer[_user]=false;
    }
      
    event logDweetReported(uint id, string hashtag);
    event logDweetBanned(uint id, string hashtag, uint maintainer); // To track how many dweets were banned to specific hashtag
    event logDweetFreed(uint id, string hashtag, uint maintainer); // To track how many dweets were banned to specific hashtag
    
    /// @notice Report a dweet
    /// @param _dweetId Id of the dweet to be reported
    function reportDweet(uint _dweetId) public payable onlyActiveDweet(_dweetId) onlyAllowedUser(msg.sender) paidEnoughforReporter checkValueforReporter{
        require(dweets[_dweetId].reportCount<=noOfReportsRequired,"Dweet have got required no of Reports");
        require(!dweetReporters[_dweetId][msg.sender],"You have already Reported!");
        dweetReporters[_dweetId][msg.sender]=true;//Reentracy attack Prevented
        userReportList[msg.sender].push(_dweetId);
        claimedReward[_dweetId][msg.sender]=userdweetReportingStatus.Reported;
         dweets[_dweetId].reportCount=dweets[_dweetId].reportCount.add(1);
        uint reports= dweets[_dweetId].reportCount;
        if(reports==noOfReportsRequired){
          dweetsReportedList.push(_dweetId);
          emit logDweetReported(_dweetId, dweets[_dweetId].hashtag);
        }
    }
    
    /// @notice Take action on a reported dweets
    /// @param _dweetId Id of dweets
    /// @param _action ban or free, true or false
    function takeAction(uint _dweetId, bool _action) public onlyMaintainer onlyActiveDweet(_dweetId) onlyAllowedUser(msg.sender){
        require(actionOnDweet[_dweetId]==reportAction.NP,"Action already taken!");
        if(_action){
          actionOnDweet[_dweetId]=reportAction.Banned;
          banDweet(_dweetId);
        }else{
          actionOnDweet[_dweetId]=reportAction.Free;
          fakeReportingReward[dweets[_dweetId].author]=fakeReportingReward[dweets[_dweetId].author].add(reportingstakePrice.mul(noOfReportsRequired));
          emit logDweetFreed(_dweetId, dweets[_dweetId].hashtag, maintainerId[msg.sender]);
        }
    }
      
    /// @notice Claim right reporting reward
    /// @param _id Id of dweet on which reward is to be claimed  
    function claimReportingReward(uint _id) public onlyAllowedUser(msg.sender){
        require(claimedReward[_id][msg.sender]==userdweetReportingStatus.Reported,"You have not reported or already claimed");
        require(userReportList[msg.sender].length>0);
        require(actionOnDweet[_id]==reportAction.Banned,"Not eligible for reward, Dweet has been freed my mainatiners");
        claimedReward[_id][msg.sender]=userdweetReportingStatus.Claimed;//Reentracy Prevented
        msg.sender.transfer(reportingRewardPrice);
    }
    
    /// @notice Claim fake reporting reward(suit)
    function claimSuitReward()public onlyAllowedUser(msg.sender){
        require(fakeReportingReward[msg.sender]>0,"Not enough balance");
        uint amount=fakeReportingReward[msg.sender];
        fakeReportingReward[msg.sender]=0;//Attack Prevented
        msg.sender.transfer(amount);
    }
    
    /// @notice To get list of reportings done by a user
    /// @param list Array of dweet Ids reported by user
    function myReportings() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
        return userReportList[msg.sender];
    }
    
    //   function myReportingReward() public view onlyAllowedUser(msg.sender) returns(uint balance){
    //       return userRewards[msg.sender];
    //   }
    
    /// @notice To get claim status of reporting
    /// @param _id Id of dweetsReportedList
    /// @return status status of claim reported or claimed
    function reportingClaimStatus(uint _id) public view onlyAllowedUser(msg.sender) returns(userdweetReportingStatus status){
        return claimedReward[_id][msg.sender];
    }
    
    /// @notice To get fake reporting reward balance
    /// @return balance reward balance of user
    function fakeReportingSuitReward() public view onlyAllowedUser(msg.sender) returns(uint balance){
        return fakeReportingReward[msg.sender];
    }
    
    /// @notice To get list of reported dweets on the platform
    /// @return list Array of reported dweet ids
    function getReportedDweets() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
        return(dweetsReportedList);
    }
    
    /// @notice Get action status of reporting on a dweet
    /// @param _dweetId Id of dweet
    /// @return status status of action NP-BAN_FREE
    function getReportedDweetStatus(uint _dweetId) public view onlyAllowedUser(msg.sender) returns(reportAction status){
        return(actionOnDweet[_dweetId]);
    }
    
/*
*******************************************Advertisement **************************************************************
*/
    uint public advertisementCost=96822938914524992;
    uint public totalAdvertisements=0;
    uint[] private advertisementsList;
    
    enum AdApprovalStatus{NP, Approved, Rejected}
    
    struct Advertisement{
        uint id;
        address advertiser;
        string imgHash;
        string link;
        AdApprovalStatus status;// Advertisement Approve or Rejected
        uint expiry; //timestamp to put expiry of Advertisement
    }
    
    modifier paidEnoughforAdvertisement() { require(msg.value >= advertisementCost); _;}
    modifier checkValueforAdvertisement() {
        _;
        uint amountToRefund = msg.value - advertisementCost;
        msg.sender.transfer(amountToRefund);
    }
    
    mapping(address=>uint[]) public advertiserAdvertisementsList;
    mapping(uint=>Advertisement) private advertisements;
    
    event logAdvertisementApproved(uint id, uint maintainer);
    event logAdvertisementRejected(uint id, uint maintainer);
    
    
    /// @notice Submit a new advertisement
    /// @param _imgHash Ipfs hash of image to be shown as advertisement
    /// @param _link Href link for the advertisement
    function submitAdvertisement(string memory _imgHash, string memory _link) public payable onlyAllowedUser(msg.sender) paidEnoughforAdvertisement checkValueforAdvertisement{
        totalAdvertisements=totalAdvertisements.add(1);
        uint id=totalAdvertisements;
        advertisements[id]=Advertisement(id, msg.sender, _imgHash, _link, AdApprovalStatus.NP, 0);
        advertisementsList.push(id);
        advertiserAdvertisementsList[msg.sender].push(id);
    }
    
    /// @notice Approve or reject advertisements
    /// @param _id Id of advertisement
    /// @param _decision Approval decision Accepted or Rejected, true or false
    function advertisementApproval(uint _id, bool _decision) public onlyMaintainer{
        require(advertisements[_id].status==AdApprovalStatus.NP,"Approval already given!");
        if(_decision){
            advertisements[_id].status=AdApprovalStatus.Approved;
            advertisements[_id].expiry=block.timestamp.add(1 days);
            emit logAdvertisementApproved(_id,maintainerId[msg.sender]);
        }else{
            advertisements[_id].status=AdApprovalStatus.Rejected;
            uint refund=advertisementCost.mul(8).div(100);
            msg.sender.transfer(refund);
            emit logAdvertisementRejected(_id,maintainerId[msg.sender]);
        }
    }
    
    /// @notice Get all ads submitted on platform
    /// @return list Array of advertisement ids
    function getAds() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
        return(advertisementsList);
    }
    
    /// @notice Get details of a advertisement
    /// @param _id Id of advertisement
    /// @return advertiser address of advertiser
    /// @return imgHash Ipfs hash of advertisement image
    /// @return link Href link of advertisement
    /// @return status Approval status of advertisements
    /// @return expiry advertisement expiry timestamp
    function getAd(uint _id) public view onlyAllowedUser(msg.sender) returns(address advertiser, string memory imgHash, string memory link, AdApprovalStatus status, uint expiry){
        return(advertisements[_id].advertiser, advertisements[_id].imgHash, advertisements[_id].link, advertisements[_id].status, advertisements[_id].expiry);
    }
    
    /// @notice Get advertisement done by user
    /// @return list Array of advertisement ids
    function myAdvertisements() public view onlyAllowedUser(msg.sender) returns(uint[] memory list){
        return(advertiserAdvertisementsList[msg.sender]);
    }
    
    /// @notice Status of a advertisement
    /// @param _id Id of advertisement
    /// @return status Approval status accepted or rejected 
    function getAdvertisementStatus(uint _id) public view onlyAllowedUser(msg.sender) returns(AdApprovalStatus status){
        return advertisements[_id].status;
    }

/*
****************************************Owner Admin ******************************************************************************************
*/
    /// @notice Get balance of contract 
    /// @return balance balance of contract
    function getBalance()public view onlyOwner() returns(uint balance){
        return address(this).balance;
    }
    
    /// @notice Withdraw contract funds to owner
    /// @param _amount Amount to be withdrawn
    function transferContractBalance(uint _amount)public onlyOwner{
        require(_amount<=address(this).balance,"Withdraw amount greater than balance");
        msg.sender.transfer(_amount);
    }
    
    function stopDapp() public onlyOwner{
        require(!stopped,"Already stopped");
        stopped=true;
    }
    
    function startDapp() public onlyOwner{
        require(stopped,"Already started");
        stopped=false;
    }
    
    function changeOwner(address payable _newOwner) public onlyOwner{
        owner=_newOwner;
    }
    
}