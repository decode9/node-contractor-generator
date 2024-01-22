// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../LibPart.sol";

abstract contract AbstractRoyalties {
    mapping (uint256 => LibPart.Part[]) internal royalties;

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) virtual internal;

    function _saveRoyalties(uint256 id, LibPart.Part[] memory _royalties) internal {
        uint256 totalValue;
        for (uint i=0;i< _royalties.length; i++) {
            require(_royalties[i].account != address(0x0), "Recipient cannot be the zero address");
            require(_royalties[i].value > 0, "Value must be greater than zero");
            totalValue += _royalties[i].value;
            royalties[id].push(_royalties[i]);
        }
        require(totalValue < 10000, "Total royalty value cannot be equal or greater than 100%");
        _onRoyaltiesSet(id, _royalties);
    }

    function _updateAccount(uint256 _id, address _from, address _to) internal {
        uint length = royalties[_id].length;
        for(uint i = 0; i < length; i++){
            if(royalties[_id][i].account == _from){
                royalties[_id][i].account = payable(address(uint160(_to)));
            }
        }
    }
        
}