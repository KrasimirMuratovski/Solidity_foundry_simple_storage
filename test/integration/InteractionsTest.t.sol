// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//auto built in foundry
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol"; //need for the deployment
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe; // make var visible below

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run(); //run() will return FundMe contract
        vm.deal(USER, STARTING_BALANCE);
        //us -> FundMeTest -> FundMe
    }

    // function testUserCanFundInteractions() public {
    //     FundFundMe fundFunMe = new FundFundMe();
    //     vm.prank(USER);
    //     vm.deal(user, 1e18);
    //     fundFunMe.fundFundMe(address(fundMe));

    //     address funder = fundMe.getFunder(0);
    //     assertEq(funder, USER);
    // }

    function testUserCanFundInteractions() public {
        FundFundMe fundFunMe = new FundFundMe();
        fundFunMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
