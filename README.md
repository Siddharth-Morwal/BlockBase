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
📄 Smart Contracts Deep-Dive1. MyToken.solToken Standard: ERC-20 (Inherited from OpenZeppelin).Decimals: 18 (Standard Wei-scaling factor).Maximum Supply Ceiling: 10,000,000 tokens ($10,000,000 \times 10^{18}$).Key Capabilities:mint(address _to, uint256 _amount): Restricts expansion privileges to the owner up to the capped maximum supply.burn(uint256 _amount): Allows tokens to be permanently deleted directly from the caller's balance.2. TokenVoting.solSecurity Guard Rails: Leverages prefixed error codes ("TokenVoting: ...") to isolate and trace transaction failures efficiently.Interface Decoupling: Implements IERC20 selectively to work with any standard ERC-20 utility implementation.Core Functions Exposed:addCandidate(string name, string description): Registers eligible candidates (Accessible only by owner while the ballot window is live).vote(uint256 candidateId, uint256 amount): Dual-action verification that locks the caller's token weight directly inside the escrow balance.closeVoting(): Closes the ballot and logs final candidate data.getWinnerId(): Internal helper loop utilizing a leading underscore (_getWinnerId) to track and declare the top-weighted candidate ID index.💻 Frontend Mechanics (voting.html)The frontend application uses Ethers.js (v5.7.2) to manage state changes seamlessly:Automated Sequential UI Flow: Clicking Approve & Vote fires an asynchronous request to the ERC-20 contract for spending permissions, waits for verification on-chain, and immediately invokes the secondary vote ballot signature.Dynamic Visualization Bars: Pulls data from getCandidate(id) to calculate percentage weights and dynamically adjust CSS progress bars.Owner-Specific Component Hiding: Evaluates votingContract.owner() to conditionally show or hide administrative functions like closeVoting() based on the connected MetaMask account.Live Voting History Logs: Uses queryFilter to dynamically parse the blockchain history for the past 5,000 blocks. It displays a live, human-readable ledger of all VoteCast events directly on the UI dashboard.Lifecycle State Transitions: When votingOpen() is updated to false on-chain, the voting control interface hides itself and displays a dedicated Winner Announced banner celebrating the successful candidate.🚀 Setup & Deployment ProtocolPhase 1: Compile & Deploy (Remix IDE)Open Remix IDE.Compile and deploy MyToken.sol using compiler environment 0.8.20 or higher on the Sepolia Testnet via MetaMask. Copy the deployed contract address.Open TokenVoting.sol and compile it. Under the deployment options, paste your copied MyToken address into the constructor input (_tokenaddress). Click Deploy and complete the MetaMask transaction.Expand your deployed TokenVoting contract options within Remix and call addCandidate to create candidate profiles.Phase 2: Connect the Frontend ConfigurationOpen your local voting.html file inside a text editor.Locate the deployment variables block around lines 65-70 and paste your live contract addresses:JavaScriptconst VOTING_ADDRESS = "0x57492757C9868c6B547E926c4D4e25b86835C5BA"; // Your TokenVoting Address
const TOKEN_ADDRESS  = "0xe97410441A677b214Ac064f2a06418AF384Dd7Ea"; // Your MyToken Address
Save changes.Phase 3: Launch Local Web ServerDue to modern browser security restrictions over standard local file directories (file:///), you must run the client UI through a local server configuration:Bash# Serve via Python local server utility
python -m http.server 8000
Open your browser window and navigate directly to http://localhost:8000/voting.html to test your governance pipeline live!
