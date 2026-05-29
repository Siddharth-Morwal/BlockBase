# Token-Weighted Governance Voting DApp

A decentralized governance voting application modeled after standard protocol architectures used by Uniswap, Compound, Aave, and MakerDAO. Participants cast weighted votes by committing custom ERC-20 tokens; the candidate who accumulates the highest total token-weight wins the election.

## 📌 How It Works

This application operates using a two-contract system paired with an interactive client-side web interface:

1. **Token Infrastructure (`MyToken.sol`):** An ERC-20 compliant token possessing a maximum supply cap of 10,000,000 tokens. Upon deployment, an initial allocation of 1,000,000 tokens is minted directly to the deployer's address.
2. **Governance Core (`TokenVoting.sol`):** The primary engine managing the election lifecycle. It accepts the token's contract address during instantiation to track weights securely using the standard OpenZeppelin `IERC20` interface.
3. **The Escrow & Ballot Pipeline:**
   * **Approve:** A voter authorizes the `TokenVoting` contract to spend a specific amount of tokens from their wallet via the standard ERC-20 `approve(spender, amount)` function.
   * **Vote:** The user calls `vote(candidateId, amount)` on the voting contract. The contract invokes `transferFrom()` to safely pull those tokens into its own escrow balance, records the transaction weight, and permanently flags the user's address as having voted.
4. **Finalization:** The designated owner closes the ballot window via `closeVoting()`. The contract freezes future ballots, aggregates the winner instantly, and emits the final event logs to the blockchain.

---

## 🛠️ Project Structure

```text
├── contracts/
│   ├── MyToken.sol         # Core ERC-20 Governance Utility Token
│   └── TokenVoting.sol     # Ballot Management and Escrow Engine
└── frontend/
    └── voting.html         # Live UI Interface Dashboard (Ethers.js v5)
```


