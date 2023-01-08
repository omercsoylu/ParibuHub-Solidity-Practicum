// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract CrowdFunding {
    receive() external payable {
        // This contract does not accept any direct transfer of assets other than its funding functions."
        revert(
            "This contract does not accept any direct transfer of assets other than its funding functions. Please check the contract to participate in the campaigns"
        );
    }

    event Launch(
        uint256 id,
        address indexed creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint256 id);
    event Deposit(uint256 indexed id, address indexed caller, uint256 amount);
    event Withdraw(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 id, address indexed caller, uint256 amount);

    struct Campaign {
        // creator of campaign
        address creator;
        // goal of campaing to withdraw
        uint256 goal;
        // total deposit of campaign
        uint256 deposit;
        // start date of the campaign
        uint32 startAt;
        // end date of the campaign
        uint32 endAt;
        // has the goal been achieved and the creator withdrawn the balance? true or false
        bool claimed;
    }

    // count of campaign and used for campaign ids;
    uint256 public campaignCount;

    // mapping from id to Campaign
    mapping(uint256 => Campaign) public campaigns;

    // mapping from campaign id to funder address to deposit amount
    mapping(uint256 => mapping(address => uint256)) public depositAmount;

    // Campaign started, startDate must be greater than block.time and duration must be less than 60 days.
    function launch(
        uint256 _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(
            _startAt >= block.timestamp,
            "start time must be greater than the current"
        );
        require(_endAt >= _startAt, "end time must be greater than the start");
        require(
            _endAt <= block.timestamp + 60 days,
            "end time must be greater than maximum duration."
        );

        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            goal: _goal,
            deposit: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(campaignCount, msg.sender, _goal, _startAt, _endAt);
    }

    // The campaign can only be canceled before it starts
    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(
            campaign.creator == msg.sender,
            "You're not creator of this campaign."
        );
        require(
            block.timestamp < campaign.startAt,
            "The campaign has started, so you cannot cancel"
        );

        delete campaigns[_id];
        emit Cancel(_id);
    }

    // Funders can participate in the campaign with "Ether". so the function is payable.
    function deposit(uint256 _id) external payable {
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp >= campaign.startAt,
            "The campaign has not started yet"
        );
        require(block.timestamp <= campaign.endAt, "The campaign is over");
        require(
            msg.value > 0,
            "You cannot deposit in the campaign with insufficient funds."
        );

        campaign.deposit += msg.value;
        depositAmount[_id][msg.sender] += msg.value;

        emit Deposit(_id, msg.sender, msg.value);
    }

    // While the campaign is active, funders can withdraw from the campaign.
    function withdraw(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(
            block.timestamp <= campaign.endAt,
            "The campaign is over, so you cannot withdraw the campaign."
        );
        require(
            campaign.deposit >= _amount,
            "You're trying to withdraw more than your deposited."
        );

        campaign.deposit -= _amount;
        depositAmount[_id][msg.sender] -= _amount;
        (bool res, ) = payable(msg.sender).call{value: _amount}("");
        require(res);

        emit Withdraw(_id, msg.sender, _amount);
    }

    // If the campaign reaches its goal, the campaign creator can withdraw the collected funds
    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(
            campaign.creator == msg.sender,
            "You're not creator of this campaign."
        );
        require(
            block.timestamp > campaign.endAt,
            "The campaign is not over yet"
        );
        require(
            campaign.deposit >= campaign.goal,
            "The amount deposited in the campaign must be greater than the campaign goal"
        );
        require(!campaign.claimed, "Already claimed.");

        campaign.claimed = true;
        (bool res, ) = payable(msg.sender).call{value: campaign.deposit}("");
        require(res);

        emit Claim(_id);
    }

    // The funders can withdraw their funds if the campaign has not reached its goal.
    function refund(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(
            block.timestamp > campaign.endAt,
            "The campaign is not over yet"
        );
        require(
            campaign.deposit < campaign.goal,
            "The campaign goal successfully achieved"
        );

        uint256 funderBalance = depositAmount[_id][msg.sender];
        depositAmount[_id][msg.sender] = 0;
        (bool res, ) = payable(msg.sender).call{value: funderBalance}("");
        require(res);

        emit Refund(_id, msg.sender, funderBalance);
    }
}
