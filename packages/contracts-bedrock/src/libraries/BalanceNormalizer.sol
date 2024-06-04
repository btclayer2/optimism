// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Metadata {
    function decimals() external view returns (uint8);
}

library BalanceNormalizer {
    ///
    /// @dev Normalizes the balance from one decimal base to another.
    /// @param origin_decimals places of the original balance
    /// @param target_decimals Decimal places to normalize the balance to
    /// @param origin_balance The original balance to normalize
    /// @return The normalized balance
    ///
    function normalize(
        uint8 origin_decimals,
        uint8 target_decimals,
        uint256 origin_balance
    )
        internal
        pure
        returns (uint256)
    {
        if (origin_decimals == target_decimals) {
            return origin_balance;
        }

        if (origin_decimals > target_decimals) {
            uint256 factor = 10 ** (origin_decimals - target_decimals);
            // Check for division overflow (unnecessary in Solidity 0.8.0+)
            return origin_balance / factor;
        } else {
            uint256 factor = 10 ** (target_decimals - origin_decimals);
            // Check for multiplication overflow (unnecessary in Solidity 0.8.0+)
            return origin_balance * factor;
        }
    }

    ///
    /// @dev Returns the remainder of the balance after normalizing to a smaller number of decimal places.
    /// This function is only applicable when reducing the number of decimals.
    /// @param origin_decimals places of the original balance
    /// @param target_decimals Decimal places to normalize the balance to, must be less than target
    /// @param origin_balance The original balance to normalize
    /// @return remainder The remainder after dividing the original balance by the factor derived from the decimal
    /// difference
    ///
    function getRemainder(
        uint8 origin_decimals,
        uint8 target_decimals,
        uint256 origin_balance
    )
        internal
        pure
        returns (uint256)
    {
        if (origin_decimals <= target_decimals) {
            // No remainder if the target decimals are not less than the origin decimals
            return 0;
        }

        uint256 factor = 10 ** (origin_decimals - target_decimals);

        // Directly return the remainder of the division
        return origin_balance % factor;
    }

    ///
    /// @dev Retrieves the number of decimals for an ERC20 token. If the call to `decimals()` fails, it defaults to 18.
    /// @param token The address of the ERC20 token contract.
    /// @return origin_decimals The number of decimals of the token, or 18 if the call fails.
    ///
    function getDecimals(address token) public view returns (uint8) {
        // Default value in case the call fails
        uint8 DEFAULT_DECIMALS = 18;

        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSignature("decimals()"));

        if (success && data.length == 32) {
            return abi.decode(data, (uint8));
        } else {
            return DEFAULT_DECIMALS;
        }
    }
}
