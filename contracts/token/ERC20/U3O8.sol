// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./presets/ERC20PresetMinterPauser.sol";

contract U3O8 is ERC20PresetMinterPauser {
    address private _commissionReceiver;
    address private _conversionCommissionReceiver;
    uint256 public commissionMultiplier;
    uint256 public commissionDivider;
    uint256 public conversionCommissionMultiplier;
    uint256 public conversionCommissionDivider;
    uint256 public reverseConversionCommissionMultiplier;
    uint256 public reverseConversionCommissionDivider;
    uint256[] public allowedConversionAmouts;
    bytes32 public constant CONVERSION_ADMIN_ROLE = keccak256("CONVERSION_ADMIN_ROLE");

    constructor() ERC20PresetMinterPauser("U3O8 Uranium Token", "U3O8") {
        _mint(_msgSender(), 10000 * (10 ** uint256(decimals())));
        _setupRole(CONVERSION_ADMIN_ROLE, _msgSender());

        _commissionReceiver = _msgSender();
        _conversionCommissionReceiver = _msgSender();

        commissionMultiplier = 5;
        commissionDivider = 10000;

        conversionCommissionMultiplier = 5;
        conversionCommissionDivider = 1000;

        reverseConversionCommissionMultiplier = 0;
        reverseConversionCommissionDivider = 1;

        allowedConversionAmouts = [2800 * (10 ** uint256(decimals())), 560 * (10 ** uint256(decimals())), 100 * (10 ** uint256(decimals()))];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        uint256 multiplier = commissionMultiplier;
        uint256 divider = commissionDivider;

        address feeReceiver = _commissionReceiver;

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

            feeReceiver = _conversionCommissionReceiver;
        }

        uint256 feeAmount = (amount * multiplier) / divider;
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= (amount + feeAmount), "U3O8: transfer amount plus commission exceeds balance");

        super._transfer(sender, recipient, amount);
        super._transfer(sender, feeReceiver, feeAmount);
    }

    function finalizeReverseConversion(address recipient, uint256 amount) public {
        require(hasRole(CONVERSION_ADMIN_ROLE, _msgSender()), "U3O8: must have conversion_admin role to approve reverse conversion");

        uint256 feeAmount = (amount * reverseConversionCommissionMultiplier) / reverseConversionCommissionDivider;
        uint256 senderBalance = balanceOf(address(this));
        require(senderBalance >= amount, "U3O8: transfer amount exceeds balance");
        uint256 sendAmount = amount - feeAmount;

        super._transfer(address(this), recipient, sendAmount);
        super._transfer(address(this), _conversionCommissionReceiver, feeAmount);
    }

    function setCommissionReceivers(address commissionReceiver, address conversionCommissionReceiver) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change commission receivers");
        _commissionReceiver = commissionReceiver;
        _conversionCommissionReceiver = conversionCommissionReceiver;
    }

    function setCommissionAmount(uint256 multiplier, uint256 divider) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change commission");
        commissionMultiplier = multiplier;
        commissionDivider = divider;
    }

    function setConversionCommissionAmount(uint256 multiplier, uint256 divider) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change conversion commission");
        conversionCommissionMultiplier = multiplier;
        conversionCommissionDivider = divider;
    }

    function setReverseConversionCommissionAmount(uint256 multiplier, uint256 divider) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change reverse conversion commission");
        reverseConversionCommissionMultiplier = multiplier;
        reverseConversionCommissionDivider = divider;
    }

    function setAllowedConversionAmouts(uint256[] memory newArray) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "U3O8: must have admin role to change allowed conversion amounts");
        allowedConversionAmouts = newArray;
    }
}