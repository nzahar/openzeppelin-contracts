// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC20.sol";

contract U3O8GovernanceToken is ERC20 {
    address[] private holdersList;

    constructor() ERC20("U3O8 Governance token", "U3O8G") {
        _mint(msg.sender, 30000 * 10 ** decimals());
        holdersList.push(msg.sender);
    }

    function decimals() public view virtual override returns (uint8) {
        return 1;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        bool addToArray = true;
        if (balanceOf(recipient) > 0) {
            addToArray = false;
        }

        super._transfer(sender, recipient, amount);

        if ((addToArray==true) && (balanceOf(recipient)) > 0) {
            holdersList.push(recipient);
        }
        if (balanceOf(sender) == 0) {
            _removeHolder(_getIndex(sender));
        }
    }

    function _removeHolder(uint index) internal {
        require(index < holdersList.length);
        holdersList[index] = holdersList[holdersList.length-1];
        holdersList.pop();
    }

    function _getIndex(address addr) internal view returns(uint) {
        for(uint i = 0; i<holdersList.length; i++){
            if(addr == holdersList[i]) return i;
        }
        return (holdersList.length + 1);
    }

    function getHoldersList()public view returns(address[] memory) {
        return holdersList;
    }
}
