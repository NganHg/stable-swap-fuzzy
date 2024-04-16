export const NETWORKS = {
  bscTestnet: {
    chainId: 97,
  },
  sapphireTestnet: {
    chainId: 23295,
  },
};

export const coins = {
  [NETWORKS.bscTestnet.chainId]: [
    {
      symbol: "USDC",
      address: "0x9b20cBFbC710147f1c9493bd365156B155aBC453",
      decimals: "6",
    },
    {
      symbol: "USDT",
      address: "0xf76C95DE78a6A437142aAe382167303C3709078A",
      decimals: "6",
    },
    {
      symbol: "DAI",
      address: "0x0C9999C291EE7a390A7C3fe4738D07da6d24E845",
      decimals: "18",
    },
    {
      symbol: "sETH",
      address: "0x4824bf014FF58cB7b02daC002d31798f0Be586Cf",
      decimals: "18",
    },
    {
      symbol: "rETH",
      address: "0x1411dF028A50B28810EC0BbdC7684AF26701c0e2",
      decimals: "18",
    },
    {
      symbol: "vETH",
      address: "0x4a40DF477C2125982207C09eE130936e43A5d9C3",
      decimals: "18",
    },
    {
      symbol: "vBNB",
      address: "0x005cdf176E3Bf461079b254DF46b22c4c69483C6",
      decimals: "18",
    },
    {
      symbol: "sBNB",
      address: "0xD3235e0EA83ff2892e9296E3ad36149f9Fb8FF24",
      decimals: "18",
    },
    {
      symbol: "sUSDC",
      address: "0x5E3FdB7Cdd29C39a53249aB906D1E1beB0b56b75",
      decimals: "6",
    },
    {
      symbol: "sUSDT",
      address: "0x8B7B2c2513E35c58a498141e3448A33564f3c998",
      decimals: "6",
    },
  ],
  [NETWORKS.sapphireTestnet.chainId]: [
    {
      symbol: "USDC",
      address: "0xB649cF2Fca36CaB5dCd4aFC51cC901a4b3cff4a8",
      decimals: "6",
    },
    {
      symbol: "USDT",
      address: "0x23c0E9Ee4f639BBED3689Db1659a50148116195D",
      decimals: "6",
    },
    {
      symbol: "DAI",
      address: "0xc78F6eA52991BFB16e22d0A2134c78f478b25913",
      decimals: "18",
    },
    {
      symbol: "sETH",
      address: "0xEF86D06992e8440ACA9Ab34b3B7d407C5cb2934d",
      decimals: "18",
    },
    {
      symbol: "rETH",
      address: "0xc8a31c0fbbebFcA00f353b7DC72a6A1D4112287C",
      decimals: "18",
    },
    {
      symbol: "vETH",
      address: "0xE36AeaB3AE715a436380452391EEFa2cD653b475",
      decimals: "18",
    },
    {
      symbol: "vBNB",
      address: "0x312F99EEfa77C1b2E6712CBbC1Bbb17DD5745D77",
      decimals: "18",
    },
    {
      symbol: "sBNB",
      address: "0x39557d6aA3ed5efD7c1aD977c16bDb2aC99716f8",
      decimals: "18",
    },
    {
      symbol: "sUSDC",
      address: "0xa287B7dB0d4a210735B95E163cC35419e0ec4332",
      decimals: "6",
    },
    {
      symbol: "sUSDT",
      address: "0x98E1A535ED35ED4aB75AB41615227325521077DD",
      decimals: "6",
    },
  ],
};

export const listAddr = {
  [NETWORKS.bscTestnet.chainId]: {
    StableSwapInfo: "0xec36d72EA6D6436EB0fe69C72017D43A1a79D7FB",
    StableSwapThreePoolInfo: "0x7EB51b2dd9a989e33EeD0721b703C16F4D85EFD7",
    StableSwapTwoPoolInfo: "0xC35b4168Ac96D81158Df66bc778ddc786203933e",
    StableSwapLPFactory: "0xD49157e5FD3F49224D734DA99cB063001bad8eFa",
    StableSwapTwoPoolDeployer: "0xaeCb6253844c1c8f849b0F36f50eaea92286d352",
    StableSwapThreePoolDeployer: "0x36E0A19d121FF1f6d14d32633994Ae04f5fCc75c",
    StableSwapFactory: "0x70711cb5044a21dC76501c423862b39BF4628B05",
    SmartRouterHelperLibrary: "0x205c5D534b8848f4c399414B10Bee526Dca7a8dA",
    StableSwapRouter: "0x6a1a21b1BA32e9749Ac07Dfe4B4A0F70aDc4026e",
  },
  [NETWORKS.sapphireTestnet.chainId]: {
    StableSwapInfo: "0x73a15db39E99c23e9C0928b4be01D0DA496D8e35",
    StableSwapThreePoolInfo: "0x63e504af9Dea2981a002187B9c2BdD8C0e79B2f2",
    StableSwapTwoPoolInfo: "0xd930F92324007AdAC530847D5DD3511249547b48",
    StableSwapLPFactory: "0xed830DFEb8FcDEBab5DA36773EC986aB4C27c53E",
    StableSwapTwoPoolDeployer: "0x3484dD477dbF36a5C94d67F54890D73d09B9Aff1",
    StableSwapThreePoolDeployer: "0xd83F21A1a7A175001245a6631366a0CAefD0ccaC",
    StableSwapFactory: "0x5211c84b98Dcfb362A4ADdc122Fd47EE47edFFad",
    SmartRouterHelperLibrary: "0xd29CB0859eb20931Eae783729089E0dc6A86e9c9",
    StableSwapRouter: "0x9dd45083F444Dc1d32bF4acc5490ba01af7B0fda",
  },
};

export const poolList = {
  [NETWORKS.bscTestnet.chainId]: [
    {
      type: 3,
      tag: "USD",
      name: "3Pool",
      code: "USDC USDT DAI",
      address: "0xE757Df9854C6090770bDECad2f494FBD4d2246ED",
      lpAddress: {
        symbol: "crvUSD",
        address: "0xD74d1b99A6F6e8C7E2ad4665B72483Fcdc7432bE",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "DAI",
          address: "0x0C9999C291EE7a390A7C3fe4738D07da6d24E845",
          decimals: 18,
        },
        {
          symbol: "USDC",
          address: "0x9b20cBFbC710147f1c9493bd365156B155aBC453",
          decimals: 6,
        },
        {
          symbol: "USDT",
          address: "0xf76C95DE78a6A437142aAe382167303C3709078A",
          decimals: 6,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 3,
      tag: "ETH",
      name: "srvETH",
      code: "sETH rETH vETH",
      address: "0xDD02D75dc1AF9Dfc103007624277F9A1019CC2Ad",
      lpAddress: {
        symbol: "srvETH",
        address: "0x0EbC822a8010a05D107c0fFF345923EB756a8774",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "rETH",
          address: "0x1411dF028A50B28810EC0BbdC7684AF26701c0e2",
          decimals: 18,
        },
        {
          symbol: "sETH",
          address: "0x4824bf014FF58cB7b02daC002d31798f0Be586Cf",
          decimals: 18,
        },
        {
          symbol: "vETH",
          address: "0x4a40DF477C2125982207C09eE130936e43A5d9C3",
          decimals: 18,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 2,
      tag: "BNB",
      name: "sBNB-vBNB",
      code: "sBNB vBNB",
      address: "0xB6843FF108D2aAEEED8Aaa15eA2c1ec569Eff240",
      lpAddress: {
        symbol: "svBNB",
        address: "0x4fb23FcA628867b5692b45bf51ad10299d207182",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "vBNB",
          address: "0x005cdf176E3Bf461079b254DF46b22c4c69483C6",
          decimals: 18,
        },
        {
          symbol: "sBNB",
          address: "0xD3235e0EA83ff2892e9296E3ad36149f9Fb8FF24",
          decimals: 18,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 2,
      tag: "USD",
      name: "sUSDC-sUSDT",
      code: "sUDSC sUSDT",
      address: "0x50d503dD9EB325d3b7DDDD8D4758E66d95c9c594",
      lpAddress: {
        symbol: "sUSDCT",
        address: "0xc906BAE136F5DAbF68a9dcc8425f2AA1228f1E1a",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "sUSDC",
          address: "0x5E3FdB7Cdd29C39a53249aB906D1E1beB0b56b75",
          decimals: 6,
        },
        {
          symbol: "sUSDT",
          address: "0x8B7B2c2513E35c58a498141e3448A33564f3c998",
          decimals: 6,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 2,
      tag: "USD",
      name: "sUSDC-USDC",
      code: "sUDSC USDC",
      address: "0xfE01B62E171cB12A845FBb7072b4693b0e29bcCa",
      lpAddress: {
        symbol: "sUSDC/USDC",
        address: "0x112F6c12fd1B9005a01E226eC94c9dbB3483760e",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "sUSDC",
          address: "0x5E3FdB7Cdd29C39a53249aB906D1E1beB0b56b75",
          decimals: 6,
        },
        {
          symbol: "USDC",
          address: "0x9b20cBFbC710147f1c9493bd365156B155aBC453",
          decimals: 6,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
  ],
  [NETWORKS.sapphireTestnet.chainId]: [
    {
      type: 3,
      tag: "USD",
      name: "3Pool",
      code: "USDC USDT DAI",
      address: "0x87d41Dc34e9a685E476f2859C18AfFa12e03dF34",
      lpAddress: {
        symbol: "crvUSD",
        address: "0x510650f33F7c11fA5E590876beFF793282d96839",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "USDT",
          address: "0x23c0E9Ee4f639BBED3689Db1659a50148116195D",
          decimals: 6,
        },
        {
          symbol: "USDC",
          address: "0xB649cF2Fca36CaB5dCd4aFC51cC901a4b3cff4a8",
          decimals: 6,
        },
        {
          symbol: "DAI",
          address: "0xc78F6eA52991BFB16e22d0A2134c78f478b25913",
          decimals: 18,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 3,
      tag: "ETH",
      name: "srvETH",
      code: "sETH rETH vETH",
      address: "0xD278abA02C181bae1644ba1275663Bbc23194C1B",
      lpAddress: {
        symbol: "srvETH",
        address: "0x22a0AE491c50f4c1CEB417b04965A02f54B32558",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "rETH",
          address: "0xc8a31c0fbbebFcA00f353b7DC72a6A1D4112287C",
          decimals: 18,
        },
        {
          symbol: "vETH",
          address: "0xE36AeaB3AE715a436380452391EEFa2cD653b475",
          decimals: 18,
        },
        {
          symbol: "sETH",
          address: "0xEF86D06992e8440ACA9Ab34b3B7d407C5cb2934d",
          decimals: 18,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 2,
      tag: "BNB",
      name: "sBNB-vBNB",
      code: "sBNB vBNB",
      address: "0x8e37dfbFF2C00993d50DDDfeA97ec2c3C8ED4c6D",
      lpAddress: {
        symbol: "svBNB",
        address: "0x45ac7D9914A54FFd857dD62Cc161b350454E7D89",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "vBNB",
          address: "0x312F99EEfa77C1b2E6712CBbC1Bbb17DD5745D77",
          decimals: 18,
        },
        {
          symbol: "sBNB",
          address: "0x39557d6aA3ed5efD7c1aD977c16bDb2aC99716f8",
          decimals: 18,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 2,
      tag: "USD",
      name: "sUSDC-sUSDT",
      code: "sUDSC sUSDT",
      address: "0xd49D92b23efbB64d1270A28f07B150962a2bD896",
      lpAddress: {
        symbol: "sUSDCT",
        address: "0xE7792dF0E61179e76778B03adccB77f630667272",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "sUSDT",
          address: "0x98E1A535ED35ED4aB75AB41615227325521077DD",
          decimals: 6,
        },
        {
          symbol: "sUSDC",
          address: "0xa287B7dB0d4a210735B95E163cC35419e0ec4332",
          decimals: 6,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
    {
      type: 2,
      tag: "USD",
      name: "sUSDC-USDC",
      code: "sUDSC USDC",
      address: "0xc5144F1465Ef5c973bF0570Da15fDa5932976108",
      lpAddress: {
        symbol: "sUSDC/USDC",
        address: "0x6342213Ef85edACd8a1dAAdc765e64C21Dc33aA1",
        decimals: 18,
      },
      underlyingTokens: [
        {
          symbol: "sUSDC",
          address: "0xa287B7dB0d4a210735B95E163cC35419e0ec4332",
          decimals: 6,
        },
        {
          symbol: "USDC",
          address: "0xB649cF2Fca36CaB5dCd4aFC51cC901a4b3cff4a8",
          decimals: 6,
        },
      ],
      fee: 0.01,
      DAOFee: 0.005,
    },
  ],
};
