const dwitter = artifacts.require("Dwitter");

contract("Dwitter", async (accounts) => {
  
    const user=accounts[0];

    beforeEach(async () => {
        instance = await dwitter.deployed()
    });

    it("Checking User Registration", async () => {
        let username="check";
        let name="checkName";
        let imgHash="checkImg";
        let coverImg="checkCover"
        let bio="testing";
        await instance.registerUser(username,name,imgHash,coverImg,bio,{from:user});
        let res=instance.getUser().call(user); 

        assert.equal(
            "hjadhjsja",
            returenedValue,
            "Test failed, value was not same"
        );
    });
});