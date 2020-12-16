// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.10;
import "./safeMath.sol";

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
            string bio;
            accountStatus status; // Account Banned or not
        }
        
        struct Dweet{
            uint dweetId;
            address author;
            string hashtag;
            string content;
            string imgHash;
            uint likeCount;
            uint reportCount;
            dweetStatus status; // Dweet Reported and Banned or not
        }
        
        struct Comment{
            uint commentId;
            address author;
            uint dweetId;
            string content;
            uint likeCount;
            uint reportCount;
            commentStatus status; // Comment Reported and Banned or not
        }
        
        uint public totalDweets=0;
        uint public totalComments=0;
        uint public totalUsers=0;
        
        ///@dev NP means not present the default value for status 
        enum accountStatus{NP,Active,Banned,Deactivated}
        enum commentStatus{NP,Active, Banned, Deleted}
        enum dweetStatus{NP,Active, Banned, Deleted}
        
        mapping(address=>User) private users; //mapping to get user details from user address
        mapping(string=>address) private userAddressFromUsername;//to get user address from username
        // mapping(address=>bool) private registeredUser; //mapping to get user details from user address
        mapping(string=>bool) private usernames;//To check which username is taken taken=>true, not taken=>false

        
        mapping(uint=>Dweet) private dweets;// mapping to get dweet from Id
        mapping(address=>uint[]) private userDweets; // Array to store dweets(Id) done by user
        mapping(uint=>mapping(address=>bool)) private dweetReporters; // Mapping to track who reported which dweet
        mapping(uint=>address[]) private dweetReportersList;
        mapping(uint=>mapping(address=>bool)) private dweetLikers; // Mapping to track who liked which dweet
        
        mapping(uint=>Comment) private comments; //Mapping to get comment from comment Id
        mapping(address=>uint[]) private userComments;// Mapping to track user comments from there address
        mapping(uint=>mapping(address=>bool)) private commentReporters; // Mapping to track who reported which comment
        mapping(uint=>mapping(address=>bool)) private commentLikers; // Mapping to track who liked on which comment
        mapping(uint=>uint[]) private dweetComments; // Getting comments for a specific dweet
        


        
       
        
        modifier stopInEmergency { require(!stopped); _; }
        modifier onlyInEmergency { require(stopped); _; }
        
        modifier onlyOwner{require(msg.sender==owner); _;}
        modifier onlyDweetAuthor(uint id){require(msg.sender==dweets[id].author); _;}
        modifier onlyCommentAuthor(uint id){require(msg.sender==comments[id].author); _;}
        modifier onlyMaintainers(address user){require(maintainers[user].stakeBalance>0); _;}
        modifier onlyAllowedUser(address user){require(users[user].status==accountStatus.Active); _;}
        modifier onlyActiveDweet(uint id){require(dweets[id].status==dweetStatus.Active); _;}
        modifier onlyActiveComment(uint id){require(comments[id].status==commentStatus.Active); _;}
        modifier usernameTaken(string memory username){require(!usernames[username]); _;}
        // modifier checkUserExists(){require(registeredUser[msg.sender]); _;}
        modifier checkUserNotExists(address user){require(users[user].status==accountStatus.NP); _;}

        
        event logRegisterUser(address user, uint id);
        event logUserBanned(address user, uint id);
        event logDweetCreated(address author, uint userid, uint dweetid, string hashtag);
        event logDweetBanned(uint id, string hashtag); // To track how many dweets were banned to specific hashtag
        event logDweetDeleted(uint id, string hashtag);
        event logCommentBanned(uint id, string hashtag);
        
        constructor() public{
            owner=msg.sender;
        }
        
        
        function usernameAvailable(string memory _username) public view returns(bool status){
            return !usernames[_username];
        }
        
        function registerUser(string memory _username, string memory _name, string memory _imgHash, string memory _bio ) public checkUserNotExists(msg.sender) usernameTaken(_username){
            /// Reentrancy attack Prevented
            usernames[_username]=true;
            users[msg.sender]=User(++totalUsers, msg.sender, _username, _name, _imgHash, _bio, accountStatus.Active);
            userAddressFromUsername[_username]=msg.sender;
            emit logRegisterUser(msg.sender, totalUsers);
        }
        
        function changeUsername(string memory _username) public onlyAllowedUser(msg.sender) usernameTaken(_username){
            users[msg.sender].username=_username;
        }
        
        function banUser(address _user) internal onlyAllowedUser(_user) {
            delete users[_user];
            users[_user].status=accountStatus.Banned;
            emit logUserBanned(msg.sender, users[_user].id);
        }
        
        function createDweet(string memory _hashtag, string memory _content, string memory _imghash) public onlyAllowedUser(msg.sender) {
            dweets[++totalDweets]=Dweet(totalDweets, msg.sender, _hashtag, _content, _imghash, 0, 0, dweetStatus.Active);
            userDweets[msg.sender].push(totalDweets);
            emit logDweetCreated(msg.sender, users[msg.sender].id, totalDweets, _hashtag);
        }
        
        function banDweet(uint _id) internal{
            emit logDweetBanned(_id, dweets[_id].hashtag);
            delete dweets[_id];
            dweets[_id].status=dweetStatus.Banned;
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
            dweets[_id].status=dweetStatus.Deleted;
            for(uint i=0;i<dweetComments[_id].length;i++){
                delete dweetComments[_id][i];
            }
            delete dweetComments[_id];
        }
        
        function createComment(uint _dweetid, string memory _comment) public onlyAllowedUser(msg.sender)  onlyActiveDweet(_dweetid){
            comments[++totalComments]=Comment(totalComments, msg.sender, _dweetid, _comment, 0, 0, commentStatus.Active);
            userComments[msg.sender].push(totalComments);
            dweetComments[_dweetid].push(totalComments);
        }
        
        function banComment(uint _id) internal {
            emit logCommentBanned(_id, dweets[comments[_id].dweetId].hashtag);
            delete comments[_id];
            comments[_id].status=commentStatus.Banned;
        }
        
        function editComment(uint _commentid, string memory _comment) public onlyAllowedUser(msg.sender)  onlyActiveComment(_commentid) onlyCommentAuthor(_commentid){
            comments[_commentid].content=_comment;
        }
        
        function deleteComment(uint _id) public onlyActiveComment(_id) onlyAllowedUser(msg.sender) onlyCommentAuthor(_id) {
            delete comments[_id];
            comments[_id].status=commentStatus.Deleted;
        }
        
        function getDweet(uint _id) public onlyAllowedUser(msg.sender) onlyActiveDweet(_id) view returns (uint dweetId, address author, string memory hashtag, string memory content, string memory imgHash, uint likeCount ){
            return (dweets[_id].dweetId, dweets[_id].author, dweets[_id].hashtag, dweets[_id].content, dweets[_id].imgHash, dweets[_id].likeCount);
        }
        
        function getUserDweets() public view onlyAllowedUser(msg.sender) returns(uint[] memory dweetList){
            return userDweets[msg.sender];
        }
        
        function getComment(uint _id) public view onlyAllowedUser(msg.sender) onlyActiveComment(_id) returns(uint commentId, address author, uint dweetId, string memory content, uint likeCount, commentStatus status){
            return(comments[_id].commentId, comments[_id].author, comments[_id].dweetId, comments[_id].content, comments[_id].likeCount, comments[_id].status);
        }
        
        /// @dev Though onlyAllowedUser can be bypassed easily but still keeping for general audience 
        function getUserComments() public view onlyAllowedUser(msg.sender) returns(uint[] memory commentList){
            return userComments[msg.sender];
        }
        

        /*
        To ban dweet/comment atleast 1 % reports of total users registered on platform are needed, they need to stake ether to get reward
        After 1 % Reports the post will go to the maintainers, decision that comes from majority of participating maintainers is final for banning a dweet
        To become a maintainer they need to stake ethers 
        The maintainer should be active if he doesn't participate in more than 3 reportings then the staked amount will be captured and he need to
        again stake amount to become maintainer
        Same happens if maintainer loses majority decision, 2 % of staked amount will be captured
        24 hrs will be given to maintainers to Decide is reproting correct or not
        The winning majority and reporters will get rewards as per there staked amount
        */
        
        struct maintainer{
            uint stakeBalance;
            uint totalActions;
            uint correctActions;
            uint wrongActions;
            uint missedActions;
            uint rewards;
        }
        
        modifier paidEnoughforMaintainer() { require(msg.value >= calculateMaintainerStake()); _;}
        
        modifier checkValueforMaintainer() {
            _;
            uint amountToRefund = msg.value - calculateMaintainerStake();
            msg.sender.transfer(amountToRefund);
        }
        
        modifier paidEnoughforReporter() { require(msg.value >= reportingstakePrice); _;}
        
        modifier checkValueforReporter() {
            _;
            uint amountToRefund = msg.value - reportingstakePrice;
            msg.sender.transfer(amountToRefund);
        }
        
        event logMaintainerRegistered(address maintainer);
        event logNewPostReported(uint id, string hashtag);
        
        

    
        
        function becomeMaintainer() public payable onlyAllowedUser(msg.sender) paidEnoughforMaintainer checkValueforMaintainer{
            require(maintainers[msg.sender].stakeBalance==0);
            maintainers[msg.sender].stakeBalance=msg.value;
            totalMaintainers++;
            emit logMaintainerRegistered(msg.sender);
        }
        
        function calculateMaintainerStake() public view returns(uint){
            uint price=totalRActions.div(totalReportsPending);
            price=maintainerStakePrice.mul(price).mul(10).mul(totalMaintainers).div(totalUsers);
            if(price<maintainerStakePrice){
                return maintainerStakePrice;
            }else{
                return price;
            }
        }
        
        
        uint public maintainerStakePrice=121567164097875008;//5000 Ruppee
        uint public reportingstakePrice=23028896012875;//100 Ruppee
        uint public reportingRewardPrice=23028896012875;//100 Ruppee
        uint public ValidNoOfReportsForAction=10;
        uint private totalMaintainers=0;
        uint private totalRActions=0;//No of reports on which maintainers have taken action
        uint private totalReportsPending=0;
        mapping(address=>uint) private userTotalReports;//count of reports done till now on a user post's, includes final ones that are accepted by maintainers
        mapping(address=>maintainer) private maintainers;//Mapping to check weather a address is maintainer or not
        mapping(address=>uint) private userRewards;
        mapping(address=>uint) private reportingStakeBalance;
        
        mapping(uint=>mapping(address=>bool)) public dweetMaintainerAction;
        mapping(uint=>uint) private dweetMaintanerPositiveAction;
        mapping(uint=>uint) private dweetMaintanerNegativeAction;
        
        uint[] private reportedDweetsForAction;
        
        function reportDweet(uint _id) public payable onlyAllowedUser(msg.sender) onlyActiveDweet(_id) paidEnoughforReporter checkValueforReporter {
            require(dweets[_id].reportCount<ValidNoOfReportsForAction);
            require(!dweetReporters[_id][msg.sender]);
            dweetReporters[_id][msg.sender]=true;
            dweetReportersList[_id].push(msg.sender);
            if(++dweets[_id].reportCount>=ValidNoOfReportsForAction){
                logNewPostReported(_id,dweets[_id].hashtag);
                totalReportsPending++;
                reportedDweetsForAction.push(_id);
            }
        }
        
          
          
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        
        
        
        
        
        
        
        
        
    }