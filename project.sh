#!/bin/bash

# Project Name
PROJECT_NAME="mycoin-project"

# Step 1: Create and enter project directory
mkdir $PROJECT_NAME && cd $PROJECT_NAME

# Step 2: Initialize Node.js project
npm init -y

# Step 3: Install Hardhat and dependencies
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts

# Step 4: Initialize Hardhat
npx hardhat init --template

# Step 5: Create Contracts
mkdir -p contracts

# MyCoin.sol
cat > contracts/MyCoin.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC1363} from "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyCoin is ERC20, ERC20Burnable, ERC1363, ERC20Permit, Ownable {
    constructor(address initialOwner)
            ERC20("MyCoin", "MCOIN")
                    Ownable(initialOwner)
                            ERC20Permit("MyCoin")
                                {}

                                    function mint(address to, uint256 amount) public onlyOwner {
                                            _mint(to, amount);
                                                }
                                                }
                                                EOF

                                                # Staking.sol
                                                cat > contracts/Staking.sol << 'EOF'
                                                // SPDX-License-Identifier: MIT
                                                pragma solidity ^0.8.27;

                                                import "./MyCoin.sol";

                                                contract Staking {
                                                    MyCoin public token;
                                                        uint256 public constant APR = 5;

                                                            struct StakeInfo {
                                                                    uint256 amount;
                                                                            uint256 since;
                                                                                }

                                                                                    mapping(address => StakeInfo) public stakes;

                                                                                        constructor(MyCoin _token) {
                                                                                                token = _token;
                                                                                                    }

                                                                                                        function stake(uint256 amount) external {
                                                                                                                require(amount > 0, "Zero stake");
                                                                                                                        token.transferFrom(msg.sender, address(this), amount);
                                                                                                                                stakes[msg.sender].amount += amount;
                                                                                                                                        stakes[msg.sender].since = block.timestamp;
                                                                                                                                            }

                                                                                                                                                function unstake() external {
                                                                                                                                                        StakeInfo memory info = stakes[msg.sender];
                                                                                                                                                                require(info.amount > 0, "Nothing staked");

                                                                                                                                                                        uint256 time = block.timestamp - info.since;
                                                                                                                                                                                uint256 reward = (info.amount * time * APR) / (100 * 365 days);

                                                                                                                                                                                        delete stakes[msg.sender];
                                                                                                                                                                                                token.transfer(msg.sender, info.amount + reward);
                                                                                                                                                                                                    }
                                                                                                                                                                                                    }
                                                                                                                                                                                                    EOF

                                                                                                                                                                                                    # Airdrop.sol
                                                                                                                                                                                                    cat > contracts/Airdrop.sol << 'EOF'
                                                                                                                                                                                                    // SPDX-License-Identifier: MIT
                                                                                                                                                                                                    pragma solidity ^0.8.27;

                                                                                                                                                                                                    import "./MyCoin.sol";
                                                                                                                                                                                                    import "@openzeppelin/contracts/access/Ownable.sol";

                                                                                                                                                                                                    contract Airdrop is Ownable {
                                                                                                                                                                                                        MyCoin public token;

                                                                                                                                                                                                            constructor(MyCoin _token) {
                                                                                                                                                                                                                    token = _token;
                                                                                                                                                                                                                        }

                                                                                                                                                                                                                            function airdrop(address[] calldata recipients, uint256 amount) external onlyOwner {
                                                                                                                                                                                                                                    for (uint256 i = 0; i < recipients.length; i++) {
                                                                                                                                                                                                                                                token.mint(recipients[i], amount);
                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                            EOF

                                                                                                                                                                                                                                                            # Vesting.sol
                                                                                                                                                                                                                                                            cat > contracts/Vesting.sol << 'EOF'
                                                                                                                                                                                                                                                            // SPDX-License-Identifier: MIT
                                                                                                                                                                                                                                                            pragma solidity ^0.8.27;

                                                                                                                                                                                                                                                            import "./MyCoin.sol";
                                                                                                                                                                                                                                                            import "@openzeppelin/contracts/access/Ownable.sol";

                                                                                                                                                                                                                                                            contract Vesting is Ownable {
                                                                                                                                                                                                                                                                MyCoin public token;

                                                                                                                                                                                                                                                                    struct Vest {
                                                                                                                                                                                                                                                                            uint256 amount;
                                                                                                                                                                                                                                                                                    uint256 releaseTime;
                                                                                                                                                                                                                                                                                        }

                                                                                                                                                                                                                                                                                            mapping(address => Vest) public locks;

                                                                                                                                                                                                                                                                                                constructor(MyCoin _token) {
                                                                                                                                                                                                                                                                                                        token = _token;
                                                                                                                                                                                                                                                                                                            }

                                                                                                                                                                                                                                                                                                                function lockTokens(address user, uint256 amount, uint256 timeInSeconds) external onlyOwner {
                                                                                                                                                                                                                                                                                                                        token.transferFrom(msg.sender, address(this), amount);
                                                                                                                                                                                                                                                                                                                                locks[user] = Vest(amount, block.timestamp + timeInSeconds);
                                                                                                                                                                                                                                                                                                                                    }

                                                                                                                                                                                                                                                                                                                                        function releaseTokens() external {
                                                                                                                                                                                                                                                                                                                                                Vest memory v = locks[msg.sender];
                                                                                                                                                                                                                                                                                                                                                        require(block.timestamp >= v.releaseTime, "Tokens still locked");

                                                                                                                                                                                                                                                                                                                                                                delete locks[msg.sender];
                                                                                                                                                                                                                                                                                                                                                                        token.transfer(msg.sender, v.amount);
                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                            EOF

                                                                                                                                                                                                                                                                                                                                                                            # Step 6: Add basic deploy script
                                                                                                                                                                                                                                                                                                                                                                            mkdir -p scripts
                                                                                                                                                                                                                                                                                                                                                                            cat > scripts/deploy.js << 'EOF'
                                                                                                                                                                                                                                                                                                                                                                            const hre = require("hardhat");

                                                                                                                                                                                                                                                                                                                                                                            async function main() {
                                                                                                                                                                                                                                                                                                                                                                                const [deployer] = await hre.ethers.getSigners();

                                                                                                                                                                                                                                                                                                                                                                                    console.log("Deploying with:", deployer.address);

                                                                                                                                                                                                                                                                                                                                                                                        const MyCoin = await hre.ethers.getContractFactory("MyCoin");
                                                                                                                                                                                                                                                                                                                                                                                            const myCoin = await MyCoin.deploy(deployer.address);
                                                                                                                                                                                                                                                                                                                                                                                                await myCoin.deployed();
                                                                                                                                                                                                                                                                                                                                                                                                    console.log("MyCoin deployed to:", myCoin.address);
                                                                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                                                                    main().catch((error) => {
                                                                                                                                                                                                                                                                                                                                                                                                        console.error(error);
                                                                                                                                                                                                                                                                                                                                                                                                            p
                                                                                                                                                                                                                                                                                                                                                                                                            rocess.exitCode = 1;
                                                                                                                                                                                                                                                                                                                                                                                                            });
                                                                                                                                                                                                                                                                                                                                                                                                            EOF

                                                                                                                                                                                                                                                                                                                                                                                                            # Step 7: Add network config template
                                                                                                                                                                                                                                                                                                                                                                                                            cat > .env << 'EOF'
                                                                                                                                                                                                                                                                                                                                                                                                            SEPOLIA_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/
                                                                                                                                                                                                                                                                                                                                                                                                            PRIVATE_KEY=M511txZJDpwrtDxNHn8YqajkJj9trrJ_
                                                                                                                                                                                                                                                                                                                                                                                                            EOF

                                                                                                                                                                                                                                                                                                                                                                                                            # Update Hardhat config
                                                                                                                                                                                                                                                                                                                                                                                                            cat > hardhat.config.js << 'EOF'
                                                                                                                                                                                                                                                                                                                                                                                                            require("@nomicfoundation/hardhat-toolbox");
                                                                                                                                                                                                                                                                                                                                                                                                            require("dotenv").config();

                                                                                                                                                                                                                                                                                                                                                                                                            module.exports = {
                                                                                                                                                                                                                                                                                                                                                                                                              solidity: "0.8.27",
                                                                                                                                                                                                                                                                                                                                                                                                                networks: {
                                                                                                                                                                                                                                                                                                                                                                                                                    sepolia: {
                                                                                                                                                                                                                                                                                                                                                                                                                          url: process.env.SEPOLIA_RPC_URL,
                                                                                                                                                                                                                                                                                                                                                                                                                                accounts: [process.env.PRIVATE_KEY],
                                                                                                                                                                                                                                                                                                                                                                                                                                    },
                                                                                                                                                                                                                                                                                                                                                                                                                                      },
                                                                                                                                                                                                                                                                                                                                                                                                                                      };
                                                                                                                                                                                                                                                                                                                                                                                                                                      EOF

                                                                                                                                                                                                                                                                                                                                                                                                                                      echo "✅ MyCoin project setup complete."
                                                                                                                                                                                                                                                                                                                                                                                                                                      echo "Next steps:"
                                                                                                                                                                                                                                                                                                                                                                                                                                      echo "1. Replace PRIVATE_KEY in .env"
                                                                                                                                                                                                                                                                                                                                                                                                                                      echo "2. Run: npx hardhat compile"
                                                                                                                                                                                                                                                                                                                                                                                                                                      echo "3. Deploy: npx hardhat run scripts/deploy.js --network eth-mainnet"

