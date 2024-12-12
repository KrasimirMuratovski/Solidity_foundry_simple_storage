// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//auto built in foundry
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol"; //need for the deployment
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // make var visible below

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //us -> FundMeTest -> FundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // new contract

        //REFACTORED VERSION
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); //run() will return FundMe contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDolarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18); //checking constant
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        //assertEq(fundMe.i_owner(), msg.sender);// FundMeTest will be the owner; msg.sender is whoever is calling FundMeTest
        //us -> FundMeTest -> FundMe - ABOVE CHECK WOUD FAIL

        //instead
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWhithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund(); //Send 0 value will be less then nthe mimimum 5$; revert
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //The next TX will be from USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunderS() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWitdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        // Arrange
        // check the balance
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        //https://book.getfoundry.sh/cheatcodes/tx-gas-price
        // uint256 gasStart=gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd=gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithDrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10; //if use numbers to generate addresses thwe number must be uint160
        uint160 startFunderIndex = 1;

        // simulating from many users
        for (uint160 i = startFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address;
            //vm.deal new address
            // this forge std library hoax do both above
            hoax(address(i), SEND_VALUE);

            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        } // ENDFOR

        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            fundMe.getOwner().balance ==
                startingOwnerBalance + startingFundMeBalance
        );
    }

    function testWithDrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10; //if use numbers to generate addresses thwe number must be uint160
        uint160 startFunderIndex = 1;

        // simulating from many users
        for (uint160 i = startFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address;
            //vm.deal new address
            // this forge std library hoax do both above
            hoax(address(i), SEND_VALUE);

            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        } // ENDFOR

        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw(); //HERE USING THE CEHEAPER FUNCTION
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            fundMe.getOwner().balance ==
                startingOwnerBalance + startingFundMeBalance
        );
    }
}
