// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IVyperStableSwap {
    function A() external view returns (uint256);
    function N_COINS() external view returns (uint256);
    function coins(uint256) external view returns (address);
    function RATES(uint256) external view returns (uint256);
    function token() external view returns (address);
    function balances(uint256 index) external view returns (uint256);
    function get_D(uint256[3] memory) external view returns (uint256);
    function get_virtual_price() external view returns (uint256);
    function calc_token_amount(
        uint256[3] memory,
        bool
    ) external view returns (uint256);
    function add_liquidity(uint256[3] memory, uint256) external;
    function remove_liquidity(uint256, uint256[3] memory) external;
    function remove_liquidity_imbalance(uint256[3] memory, uint256) external;
    function remove_liquidity_one_coin(uint256, uint256, uint256) external;
    function get_dy(int128, int128, uint256) external view returns (uint256);
    function get_dy_underlying(
        int128,
        int128,
        uint256
    ) external view returns (uint256);
    function exchange(int128, int128, uint256, uint256) external;
}
