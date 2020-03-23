pragma solidity ^0.5.12;

interface I_User {
    function() external payable;
    function pay(address payable businessOutlet_address, uint256 spending)
        external;
    function redeem(address payable businessOutlet_address, uint256 points)
        external
        returns (bool status);
}

interface I_BusinessOutlet {
    function() external payable;
    function createScheme(
        address[] calldata businessOutlets,
        string calldata schemeName,
        string calldata schemeContent,
        uint256 agreeVoteThreshold,
        uint256 rewardRatio
    ) external returns (address schemeAddress);
    function schemeInvitation(address payable schemeAddress) external;
    function vote(bool myvote) external;
    function joinRewardsScheme(myRewards newRewardInstance) external;
    function payBill(uint256 spending) external;
    function payBillByRewards(uint256 points) external returns (bool status);
}

interface I_Scheme {
    function() external payable;
    function createScheme(
        address[] calldata businessOutlets,
        string calldata schemeName,
        string calldata schemeContent,
        uint256 schemeThreshold,
        uint256 schemeRatio
    ) external;
    function vote(bool agree) external;
    function createConsensus(myRewards rw) external;
}

interface I_Rewards {
    function() external payable;
    function earnRewards(address current_client, uint256 spending)
        external
        returns (bool status);
    function redeemRewards(address current_client, uint256 points)
        external
        returns (bool status);
    function getRewardRatio() external view returns (uint256);
}

contract BusinessOutlet is I_BusinessOutlet {
    string name;
    address payable[] invitedSchemeList;
    myRewards rewardInstance;

    function() external payable {}

    constructor(string memory n) public {
        name = n;
        rewardInstance = new myRewards(1);
    }

    function createScheme(
        address[] calldata businessOutlets,
        string calldata schemeName,
        string calldata schemeContent,
        uint256 agreeVoteThreshold,
        uint256 rewardRatio
    ) external returns (address schemeAddress) {
        Scheme newScheme = new Scheme();
        rewardInstance = new myRewards(rewardRatio);
        address(newScheme).transfer(1 wei);
        newScheme.createScheme(
            businessOutlets,
            schemeName,
            schemeContent,
            agreeVoteThreshold,
            rewardRatio
        );
        return address(newScheme);
    }

    function schemeInvitation(address payable schemeAddress) external {
        schemeAddress.transfer(1 wei);
        bool alreadyExist = false;
        for (uint256 i = 0; i < invitedSchemeList.length; i++) {
            if (invitedSchemeList[i] == schemeAddress) {
                alreadyExist = true;
                break;
            }
        }
        if (alreadyExist) return;
        invitedSchemeList.push(schemeAddress);
    }

    function vote(bool myvote) external {
        for (uint256 i = 0; i < invitedSchemeList.length; i++) {
            Scheme schemeInstance = Scheme(invitedSchemeList[i]);
            schemeInstance.vote(myvote);
        }
    }

    function joinRewardsScheme(myRewards newRewardInstance) external {
        rewardInstance = newRewardInstance;
    }

    function payBill(uint256 spending) external {
        address(rewardInstance).transfer(spending);
        rewardInstance.earnRewards(msg.sender, spending);
    }

    function payBillByRewards(uint256 points) external returns (bool status) {
        return rewardInstance.redeemRewards(msg.sender, points);
    }
}

contract Scheme is I_Scheme {
    string name;
    string content;
    uint256 threshold;
    uint256 ratio;

    address payable[] invitedOutletList;
    address[] agreedOutletListTmp;
    mapping(address => bool) outletVotes;

    function() external payable {}

    function createScheme(
        address[] calldata businessOutlets,
        string calldata schemeName,
        string calldata schemeContent,
        uint256 schemeThreshold,
        uint256 schemeRatio
    ) external {
        name = schemeName;
        content = schemeContent;
        threshold = schemeThreshold;
        ratio = schemeRatio;
        for (uint256 i = 0; i < businessOutlets.length; i++) {
            address outletAddress = businessOutlets[i];
            address payable payableAddress = address(uint160(outletAddress));
            payableAddress.transfer(1 wei);
            BusinessOutlet outletInstance = BusinessOutlet(payableAddress);
            outletInstance.schemeInvitation(address(this));

            bool alreadyExist = false;
            for (uint256 x = 0; x < invitedOutletList.length; x++) {
                if (invitedOutletList[x] == payableAddress) {
                    alreadyExist = true;
                    break;
                }
            }
            if (alreadyExist) continue;
            invitedOutletList.push(payableAddress);
        }
    }

    function vote(bool agree) external {
        address votingOutlet = msg.sender;
        bool exist = false;
        for (uint256 x = 0; x < invitedOutletList.length; x++) {
            if (invitedOutletList[x] == votingOutlet) {
                exist = true;
            }
        }
        if (!exist) return;
        outletVotes[votingOutlet] = agree;
    }

    function createConsensus(myRewards rw) external {
        uint256 aggreeVote = 0;
        address[] memory agreedOutletList;
        agreedOutletListTmp = agreedOutletList;
        for (uint256 i = 0; i < invitedOutletList.length; i++) {
            address payable outeletAddress = invitedOutletList[i];
            if (outletVotes[outeletAddress]) {
                aggreeVote++;
                agreedOutletListTmp.push(outeletAddress);
            }
        }
        agreedOutletList = agreedOutletListTmp;
        if (aggreeVote < threshold) return;
        rw.setup(agreedOutletList, ratio);
        for (uint256 i = 0; i < invitedOutletList.length; i++) {
            address payable outeletAddress = invitedOutletList[i];
            if (outletVotes[outeletAddress]) {
                BusinessOutlet outletInstance = BusinessOutlet(outeletAddress);
                outletInstance.joinRewardsScheme(rw);
            }
        }
    }
}

contract myRewards is I_Rewards {
    mapping(address => uint256) rewards_ledger;
    address[] clients_list;
    uint256 reward_ratio;
    address[] outlet_list;

    function() external payable {}
    constructor(uint256 r) public {
        reward_ratio = r;
        outlet_list.push(msg.sender);
    }

    modifier onlyInOutletList {
        bool alreadyExist = false;
        for (uint256 i = 0; i < outlet_list.length; i++) {
            if (outlet_list[i] == msg.sender) {
                alreadyExist = true;
                break;
            }
        }
        require(alreadyExist);
        _;
    }

    function earnRewards(address current_client, uint256 spending)
        external
        onlyInOutletList
        returns (bool status)
    {
        bool alreadyExist = false;
        for (uint256 i = 0; i < clients_list.length; i++) {
            if (clients_list[i] == current_client) {
                alreadyExist = true;
                break;
            }
        }
        if (alreadyExist) return true;
        clients_list.push(current_client);
        uint256 rewardPt = spending * reward_ratio;
        rewards_ledger[current_client] = rewardPt;
        return false;
    }

    function redeemRewards(address current_client, uint256 points)
        external
        onlyInOutletList
        returns (bool status)
    {
        uint256 clientPoint = rewards_ledger[current_client];
        if (clientPoint < points) return false;
        rewards_ledger[current_client] = clientPoint - points;
        msg.sender.transfer(points);
        return true;
    }

    function getRewardRatio() public view returns (uint256) {
        return reward_ratio;
    }

    function setup(address[] calldata businessOutlets, uint256 ratio) external {
        outlet_list = businessOutlets;
        reward_ratio = ratio;
    }
}

contract User is I_User {
    string name;
    function() external payable {}
    constructor(string memory myName) public payable {
        name = myName;
    }
    function pay(address payable businessOutlet_address, uint256 spending)
        external
    {
        businessOutlet_address.transfer(spending);
        I_BusinessOutlet(uint160(businessOutlet_address)).payBill(spending);
    }
    function redeem(address payable businessOutlet_address, uint256 points)
        external
        returns (bool status)
    {
        return
            I_BusinessOutlet(uint160(businessOutlet_address)).payBillByRewards(
                points
            );
    }
}

contract TestCase {
    // warning:   need lots of gas: set gas limit to 30000000 to deploy this contract.
    // you should have all the above contracts deployed before deploy TestCase
    function() external payable {}
    constructor() public payable {}

    function Test01() public payable {
        // run by a test EAO with sufficient ethers (e.g., 100 ethers)
        // make sure to trnasfer ether to this contract address before running Test01()
        BusinessOutlet b0 = new BusinessOutlet("BusinessOutlet 0");
        BusinessOutlet b1 = new BusinessOutlet("BusinessOutlet 1");
        BusinessOutlet b2 = new BusinessOutlet("BusinessOutlet 2");
        address(b0).transfer(0.20 ether);
        address(b1).transfer(0.10 ether);
        address(b2).transfer(0.10 ether);
        address[] memory partners = new address[](3);
        partners[0] = address(b0);
        partners[1] = address(b1);
        partners[2] = address(b2);

        myRewards myRewardsInstance = new myRewards(1);
        address(myRewardsInstance).transfer(0.10 ether);
        address _s = b0.createScheme(
            partners,
            "Joint Promotion Plan 1",
            "Earn Points from our Partners! Earning one point for every 8 dollars spending!",
            2,
            8
        );

        address payable s = address(uint256(_s));
        b1.vote(false); // not join
        b2.vote(true); // join
        b0.vote(true); // join
        I_Scheme(s).createConsensus(myRewardsInstance); // s will populate Scheme

        I_User u0 = new User("Mary");
        I_User u1 = new User("John");
        address(u0).transfer(0.10 ether);
        address(u1).transfer(0.10 ether);
        u0.pay(address(uint160(address(b2))), 2000); // user u0 spends 2000 dollars (i.e., wei)
        u0.redeem(address(uint160(address(b2))), 200);
        u1.pay(address(uint160(address(b1))), 1000); // b1 does not join the scheme.
    }
}
