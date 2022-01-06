// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./presets/ERC20PresetMinterPauser.sol";
import "../../utils/math/SafeMath.sol";
import "../../utils/Context.sol";

contract U3O8ttToken is ERC20PresetMinterPauser {
    uint256 private _feeMultiplier;
    uint256 private _feeDivider;

    constructor() ERC20PresetMinterPauser("u3o8tt", "U3O8tt") {
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
        _feeMultiplier = 5;
        _feeDivider = 10000;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 feeAmount = (amount * _feeMultiplier) / _feeDivider;
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= (amount + feeAmount), "ERC20: transfer amount plus commission (0.05 perscent) exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount - feeAmount;
        }
        _balances[recipient] += amount;
        _balances[getRoleMember(DEFAULT_ADMIN_ROLE, 0)] += feeAmount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
}