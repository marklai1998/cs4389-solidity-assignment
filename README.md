# CS4389 Solidity Assignment

## Introduction

This repository is created for `City University HK` course `CS4389 - Decentralized Apps Development` programming assignment

All credit goes to: Mark Lai

## Assignment Requirement

Full detail please refer to `assignmentSpec.pdf`, below snippet is just try to improve the google search result of this repo

1. Put the answers of Questions 1 and 2 into the file AddressConversion.sol.
2. Put the answers of Questions 3, 4 and 5 into the file Dependency.sol.
3. Put the answers of Questions 6 and 7 into the file BusinessScheme.sol.

### Question 1 [10%]

Write a smart contract called C1 to have the following features.

C1 contains a function `address2String(address) external pure returns (string memory)` that accepts an address as a parameter and returns a string that shows the address in ASCII code format in full but without extra characters.

### Question 2 [10%]

Write a smart contract C2 that contains a function `getAddress() public returns (string memory)` that creates an instance x of contract C1, and invokes `x.address2String(address(this))`, and further format the returned string so that the string content is shown in the checksum address format and then emit the output of `x.address2String(address(this))` and the checksum address into the transaction log as an event `Addresses(string given_address, string checksum_address)`. The checksum address is also returned by `getAddress()` as a string.

### Question 3 [10%]

Copy C1 as contract C3 and copy C2 as contract C4.

Choose to implement one of the following two sets:

#### Case A

1. Modify `getAddress()` of C4 so that it creates an instance of C3 and returns the address of this C3 instance in the string format instead of returning the address of “this” in the string format.
2. Add a function `pay(uint x, address y)` to contract C3. This function will transfer x wei to the address returned by `y.getAddress()` where y is an instance of contract C4.

#### Case B

1. Modify `getAddress()` of C4 into `getAddress(address given_address)` so that it returns the given address in the string format.
2. Add a function `pay(uint x, address y)` to contract C3. This function will transfer x wei to the address returned by `y.getAddress(address(this))` where y is an instance of contract C4.  

### Question 4 [10%]

Write a contract Rewards with the following properties:

| State variables                        | Meaning                                                          |
| -------------------------------------- | ---------------------------------------------------------------- |
| mapping (address=>uint) rewards_ledger | user address maps to its reward points balance, initially empty. |
| address[] clients_list                 | A list of clients, initially empty                               |
| uint reward_ratio                      | How many reward points earned for each wei spending?             |

`function earnRewards(address current_client, uint spending) returns (bool status)`
This function will insert current_client into clients_list if current_client does not exist in clients_list, and update the reward points balance of current_client kept in rewards_ledger. The ratio between reward and spending is based on the state variable reward_ratio. The variable spending keeps the spending in wei. The function returns true if current_client exists in client_list before the function is invoked; otherwise, it returns false.  

`redeemRewards(address current_ client, uint points) returns (bool status)` This function will deduct the amount of reward points kept in rewards _ledger for current_ client by the amount of reward points specified in the second parameter of the function. It ensures that the ledger after deduction will remain non-negative. It will also make the function call msg.sender.transfer(points) that transfer certain wei equivalent to the amount of points deducted above to the contract instance that calls redeemRewards(). The function returns a Boolean value denoted by status. The function returns true if the redeemable reward points are not less than points requested and a transfer operation has been performed, otherwise, it returns false.

The value of reward_ratio is inputted as a parameter when the instance is created. This value will not be changed by the instance.

`getRewardRatio()` This function will return the conversion ratio used by the instance. 

### Question 5 [10%]

Copy C3 as contract C5. In contract C5, revise `pay(uint x)` so that the function will accept an instance rw of Rewards as input parameter, transfer x wei to rw, invoke `rw.earnRewards(this, x)` followed by `rw.redeemRewards(this, points)` where points is calculated based on the reward ratio returned by `rw.getRewardRatio()`.

### Question 6 [50%]

The basic idea of this question is to enable a businessOutlet to create a scheme for the other businessOutlets, and to join the scheme upon receiving an invitation from another businessOutlet (including itself), the businessOutlet can vote for agreeing on the scheme or vote for disagreement. A scheme is established if there are more agreed votes than a given threshold.

Write the contract BusinessOutlet and the contract Scheme with the following properties and copy Rewards as contract myRewards.

#### BusinessOutlet

⋅⋅* When creating the businessOutlet instance, the constructor of the instance accepts a string as the businessOutlet name.

⋅⋅* `createScheme(address[] businessOutlets, string scheme_name, string scheme_content, uint agree_vote_threshold, uint reward_ratio)` This function will invoke the function `createScheme(businessOutlets, scheme_name, scheme_content, agree_vote_threshold, reward_ratio)` of the instance s of Scheme. Moreover, it will pass the reward ratio to the Reward contract.

⋅⋅* `schemeInvitation(address a)` This function will receive an address of a Scheme instance that some other businessOutlet has invited this businessOutlet to vote on.

⋅⋅* `vote(bool myvote)` This function will cast the vote of the businessOutlet regarding the invited Scheme.

⋅⋅* `joinRewardsScheme(myRewards)` or `joinRewardsScheme (I_Rewards)`.` IRewards is the Interface for myRewards. You only need to implement one of these two functions. The function to be implemented will accepts an instance of myRewards.

⋅⋅* `payBill(uint spending)` This function will call earnRewards of the myRewards instance received by `joinRewardsScheme()`.

⋅⋅* `payBillByRewards (uint points)`  This function will call redeemRewards of the myRewards instance received by `joinRewardsScheme()`

#### Scheme

⋅⋅* `createScheme(address[] businessOutlets, string schemeName,  string scheme_content, uint scheme_threshold, uint ratio)` This function will ensure each address in businessOutlets is an existing contract address by transferring 1 wei to each such businessOutlet. It will send itself to each such businessOutlet in the businessOutlet list.

⋅⋅* `vote(bool agree)`.` This function will check whether the businessOutlet calling this function has been invited to make decision on the scheme, keeps track of the votes received.

⋅⋅* `createConsensus(myRewards rw)` This function will check whether the sum of votes received exceeds the scheme_threshold received via `createScheme()` of the Scheme instance. If this is the case, it passes rw to each businessOutlet that has agreed in joining the scheme.

### Question 7 [Bonus marks 10%]

Modify myRewards with the following features. Thus, after a scheme is established, a Rewards contract instance is created for a set of agreed businessOutlets. These businessOutlets can now use this joint Rewards contract to book-keep the balance of reward points of each customer.

⋅⋅* Revise earnRewards and redeemRewards so that these two functions will check whether the caller of these two functions are in the businessOutlet list provided by the Scheme instance.

⋅⋅* `setup(address[] businessOutlets, uint ratio)` This function will be called by createConsensus() before passing it to each businessOutlet in the businessOutlet list.  

## Getting Started

1. Clone the repository

2. Copy those code to [Remix IDE](https://remix.ethereum.org/)

3. Deploy the contract needed
