// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardsForOnboarding {
    address public owner;

    struct Referrer {
        uint256 rewards;
        bool exists;
    }

    struct Partner {
        address referrer;
        bool onboarded;
    }

    mapping(address => Referrer) public referrers;
    mapping(address => Partner) public partners;

    uint256 public rewardPerOnboarding = 100; // Rewards in token units

    event ReferrerAdded(address indexed referrer);
    event PartnerOnboarded(address indexed partner, address indexed referrer);
    event RewardsClaimed(address indexed referrer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    modifier validReferrer(address _referrer) {
        require(referrers[_referrer].exists, "Referrer does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Add a new referrer
    function addReferrer(address _referrer) external onlyOwner {
        require(!referrers[_referrer].exists, "Referrer already exists");
        referrers[_referrer] = Referrer(0, true);
        emit ReferrerAdded(_referrer);
    }

    // Onboard a new partner and assign rewards to the referrer
    function onboardPartner(address _partner, address _referrer) external validReferrer(_referrer) {
        require(!partners[_partner].onboarded, "Partner already onboarded");

        partners[_partner] = Partner(_referrer, true);
        referrers[_referrer].rewards += rewardPerOnboarding;

        emit PartnerOnboarded(_partner, _referrer);
    }

    // Claim rewards
    function claimRewards() external {
        require(referrers[msg.sender].exists, "You are not a referrer");
        uint256 rewardAmount = referrers[msg.sender].rewards;
        require(rewardAmount > 0, "No rewards to claim");

        referrers[msg.sender].rewards = 0;
        payable(msg.sender).transfer(rewardAmount);

        emit RewardsClaimed(msg.sender, rewardAmount);
    }

    // Fund the contract
    function fundContract() external payable onlyOwner {}

    // Get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
