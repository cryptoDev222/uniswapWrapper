//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./uniswapV3/interfaces/INonfungiblePositionManager.sol";
import "./uniswapV3/interfaces/ISwapRouter.sol";

struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
}

contract UniSwap3Wrapper {
    event Initiated(address owner);
    event NewOwner(address newOwner);
    event AcceptOwner(address owner);

    INonfungiblePositionManager nftManager =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    ISwapRouter swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address public owner;
    address private newOwner;

    /**
     * @dev To check the caller is organization owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "caller-is-not-organization-owner");
        _;
    }

    /**
     * @dev Initiate the contract with owner
     * @param _owner: Owner address
     */
    function initiate(address _owner) external {
        require(owner == address(0), "already-initiated");
        owner = _owner;
        emit Initiated(owner);
    }

    /**
     * @dev Change organization owner address
     * @param _newOwner: New owner address
     */
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != owner, "already-an-owner");
        require(_newOwner != address(0), "not-valid-address");
        require(newOwner != _newOwner, "already-a-new-owner");
        newOwner = _newOwner;
        emit NewOwner(_newOwner);
    }

    /**
     * @dev Accept new owner of organization
     */
    function acceptOwner() external {
        require(newOwner != address(0), "not-valid-address");
        require(msg.sender == newOwner, "not-owner");
        owner = newOwner;
        newOwner = address(0);
        emit AcceptOwner(owner);
    }

    /**
     * @dev Mint function which interact with Uniswap v3
     * @param mintParams: Params for mint
     */
    function mint(MintParams memory mintParams)
        external
        onlyOwner
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams(
                mintParams.token0,
                mintParams.token1,
                mintParams.fee,
                mintParams.tickLower,
                mintParams.tickUpper,
                mintParams.amount0Desired,
                mintParams.amount1Desired,
                mintParams.amount0Min,
                mintParams.amount1Min,
                address(this),
                mintParams.deadline
            );
        (tokenId, liquidity, amount0, amount1) = nftManager.mint(params);
    }

    /**
     * @dev increateLiquidity function which interact with Uniswap v3
     */
    function increaseLiquidity(
        uint256 tokenId,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 deadline
    )
        external
        onlyOwner
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        INonfungiblePositionManager.IncreaseLiquidityParams
            memory params = INonfungiblePositionManager.IncreaseLiquidityParams(
                tokenId,
                amount0Desired,
                amount1Desired,
                amount0Min,
                amount1Min,
                deadline
            );
        (liquidity, amount0, amount1) = nftManager.increaseLiquidity(params);
    }

    /**
     * @dev decreaseLiquidity function which interact with Uniswap v3
     */
    function decreaseLiquidity(
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 deadline
    ) external returns (uint256 amount0, uint256 amount1) {
        INonfungiblePositionManager.DecreaseLiquidityParams
            memory params = INonfungiblePositionManager.DecreaseLiquidityParams(
                tokenId,
                liquidity,
                amount0Min,
                amount1Min,
                deadline
            );
        (amount0, amount1) = nftManager.decreaseLiquidity(params);
    }

    /**
     * @dev collect function which interact with Uniswap v3
     */
    function collect(
        uint256 tokenId,
        uint128 amount0Max,
        uint128 amount1Max
    ) external returns (uint256 amount0, uint256 amount1) {
        INonfungiblePositionManager.CollectParams
            memory params = INonfungiblePositionManager.CollectParams(
                tokenId,
                address(this),
                amount0Max,
                amount1Max
            );
        (amount0, amount1) = nftManager.collect(params);
    }

    /**
     * @dev exactInputSingle function which interact with Uniswap v3
     */
    function exactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 deadline,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams(
                tokenIn,
                tokenOut,
                fee,
                address(this),
                deadline,
                amountIn,
                amountOutMinimum,
                sqrtPriceLimitX96
            );
        amountOut = swapRouter.exactInputSingle(params);
    }

    /**
     * @dev For receive ether
     */
    receive() external payable {}
}
