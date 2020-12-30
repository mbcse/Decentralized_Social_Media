const dwitter = artifacts.require("Dwitter");

contract("Dwitter", async (accounts) => {
  
    const owner=accounts[0];
    const user=accounts[1];

    beforeEach(async () => {
        instance = await dwitter.deployed()
    });

    it("Should Stop the Dapp", async () => {
        await instance.stopDapp({from:owner});
        let stopped=await instance.stopped();
        assert.equal(stopped,true, "Test failed, value was not same");
    });

    it("Should Start the Dapp", async () => {
        await instance.startDapp({from:owner});
        let stopped=await instance.stopped();
        assert.equal(stopped,false, "Test failed, value was not same");
    });

    it("Should Add a Maintainer", async () => {
        
        await instance.addMaintainer(user,{from:owner});
        let isMaintainer=await instance.isMaintainer(user);
        assert.equal(true,isMaintainer,"Test failed, value was not same");
    });

    it("Should Remove a Maintainer", async () => {
        await instance.revokeMaintainer(user,{from:owner});
        let isMaintainer=await instance.isMaintainer(user);
        assert.equal(false,isMaintainer,"Test failed, value was not same");
    });

    it("Should Register a user", async () => {
        let username='check';
        let name='checkName';
        let imgHash='checkImg';
        let coverImg='checkCover';
        let bio='testing';
        await instance.registerUser(username, name, imgHash, coverImg, bio,{from:user});
        let res=await instance.getUser.call(user); 
        assert.equal(2,res.id, "Test failed, value was not same");
    });

    it("Should Create a Dweet", async () => {
        let hashtag='check';
        let content='checkName';
        let imghash='checkImg';
        await instance.createDweet(hashtag,content,imghash,{from:user});
        let noofdweets=await instance.totalDweets(); 
        assert.equal(1,noofdweets, "Test failed, value was not same");
    });

    it("Should Create a advertisement", async () => {
        let imghash="check";
        let link="check";
        let adcost=await instance.advertisementCost();
        await instance.submitAdvertisement(imghash,link,{from:user,value:adcost});
        let noofads=await instance.totalAdvertisements(); 
        assert.equal(1,noofads, "Test failed, value was not same");
    });

    it("Should Accept a advertisement", async () => {
        let id=1;
        await instance.advertisementApproval(id,true,{from:owner});
        let approval=await instance.getAdvertisementStatus(id); 
        assert.equal(1,approval, "Test failed, value was not same");
    });

    it("Should Reject a advertisement", async () => {
        let imghash="check";
        let link="check";
        let adcost=await instance.advertisementCost();
        await instance.submitAdvertisement(imghash,link,{from:user,value:adcost});
        let id=await instance.totalAdvertisements();
        await instance.advertisementApproval(id,false,{from:owner});
        let approval=await instance.getAdvertisementStatus(id); 
        assert.equal(2,approval, "Test failed, value was not same");
    });

    
});