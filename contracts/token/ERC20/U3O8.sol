// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./presets/ERC20PresetMinterPauser.sol";

contract U3O8tttToken is ERC20PresetMinterPauser {
    uint256 private _feeMultiplier = 5;
    uint256 private _feeDivider = 10000;
    bytes32 public constant COMMISSION_RECEIVER_ROLE = keccak256("COMMISSION_RECEIVER_ROLE");

    constructor() ERC20PresetMinterPauser("u3o8ttt", "U3O8ttt") {
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
        _setupRole(COMMISSION_RECEIVER_ROLE, _msgSender());
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        address feeReceiver = getRoleMember(COMMISSION_RECEIVER_ROLE, 0);
        uint256 feeAmount = (amount * _feeMultiplier) / _feeDivider;
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= (amount + feeAmount), "ERC20: transfer amount plus commission (0.05 perscent) exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount - feeAmount;
        }
        _balances[recipient] += amount;
        _balances[feeReceiver] += feeAmount;

        emit Transfer(sender, recipient, amount);
        emit Transfer(sender, feeReceiver, feeAmount);

        _afterTokenTransfer(sender, recipient, amount);
    }
}