// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title MockERC20Fail
 * @notice ERC20 mock with configurable transfer/transferFrom failures
 * @dev Used for testing SafeERC20 failure paths
 */
contract MockERC20Fail {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bool public failTransferFrom;
    bool public failTransfer;
    bool public returnFalseOnFail;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function setFailTransferFrom(bool shouldFail, bool returnFalse) external {
        failTransferFrom = shouldFail;
        returnFalseOnFail = returnFalse;
    }

    function setFailTransfer(bool shouldFail, bool returnFalse) external {
        failTransfer = shouldFail;
        returnFalseOnFail = returnFalse;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (failTransfer) {
            if (returnFalseOnFail) {
                return false;
            }
            revert("MockERC20Fail: transfer failed");
        }
        require(balanceOf[msg.sender] >= amount, "MockERC20Fail: balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (failTransferFrom) {
            if (returnFalseOnFail) {
                return false;
            }
            revert("MockERC20Fail: transferFrom failed");
        }
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "MockERC20Fail: allowance");
        require(balanceOf[from] >= amount, "MockERC20Fail: balance");
        allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}
