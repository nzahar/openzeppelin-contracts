// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./presets/ERC20PresetMinterPauser.sol";

contract U3O8 is ERC20PresetMinterPauser {
    uint256 public commissionMultiplier = 5;
    uint256 public commissionDivider = 10000;
    uint256 public conversionCommissionMultiplier = 5;
    uint256 public conversionCommissionDivider = 1000;
    uint256[] public allowedConversionAmouts = [2800 * (10 ** uint256(decimals())), 560 * (10 ** uint256(decimals())), 100 * (10 ** uint256(decimals()))];
    bytes32 public constant COMMISSION_RECEIVER_ROLE = keccak256("COMMISSION_RECEIVER_ROLE");

    constructor() ERC20PresetMinterPauser("U3O8 Uranium Token", "U3O8") {
        _mint(msg.sender, 10000 * (10 ** uint256(decimals())));
        _setupRole(COMMISSION_RECEIVER_ROLE, _msgSender());
    }

    //TODO: Отправка токенов с кошелька контракта в обмен на уничтожаемый NFT. БЕЗ КОМИССИИ!!!!

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        uint256 multiplier = commissionMultiplier;
        uint256 divider = commissionDivider;

        if (recipient==address(this)) {
            bool isRevert = true;
            for (uint i; i < allowedConversionAmouts.length; i++) {
                if (allowedConversionAmouts[i] == amount) {
                    isRevert = false;
                }
            }
            if (isRevert == true) {
                revert("U3O8: amount must be in the list of alowed conversion amounts");
            }

            multiplier = conversionCommissionMultiplier;
            divider = conversionCommissionDivider;
        }

        uint256 feeAmount = (amount * multiplier) / divider;
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= (amount + feeAmount), "U3O8: transfer amount plus commission exceeds balance");
        address feeReceiver = getRoleMember(COMMISSION_RECEIVER_ROLE, 0);

        super._transfer(sender, recipient, amount);
        super._transfer(sender, feeReceiver, feeAmount);
    }

    function SetCommissionAmount(uint256 multiplier, uint256 divider) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change commission");
        commissionMultiplier = multiplier;
        commissionDivider = divider;
    }

    function SetConversionCommissionAmount(uint256 multiplier, uint256 divider) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change conversion commission");
        conversionCommissionMultiplier = multiplier;
        conversionCommissionDivider = divider;
    }

    function SetAllowedConversionAmouts(uint256[] memory new_array) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change allowed conversion amounts");
        allowedConversionAmouts = new_array;
    }
}