# ChainedSocial - Decentralized Social Media Platform

[![Built for ICP WCHL25](https://img.shields.io/badge/Built%20for-ICP%20WCHL25-blue)](https://dorahacks.io/hackathon/wchl25-qualification-round)
[![ICP](https://img.shields.io/badge/Built%20on-Internet%20Computer-orange)](https://internetcomputer.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 🌟 Vision

ChainedSocial is a fully decentralized social media platform built on the Internet Computer Protocol (ICP) blockchain. Our mission is to create a social media ecosystem where users own their data, control their content, and participate in platform governance.

## 🚀 Key Features

- **100% On-Chain**: All data stored on ICP blockchain with unlimited scalability
- **Passwordless Auth**: Secure authentication via Internet Identity
- **Community Governance**: DAO-based decision making for platform features
- **Creator Economy**: Direct monetization through ICP tokens and tips
- **Censorship Resistant**: Content stored across distributed nodes
- **Real-Time Messaging**: Instant communication between users
- **NFT Integration**: Profile pictures and collectible posts as NFTs
- **AI-Powered Discovery**: Intelligent content recommendations
- **AI integration to create images and posts**
- **Create AI agents that can talk, aggregate information, etc**

## 🏗️ Technical Architecture

### Backend (ICP Canisters)
- **Language**: Motoko
- **User Management**: Profile creation, authentication, identity verification ✅ **Implemented**
- **Content System**: Posts, comments, media uploads, moderation ✅ **Implemented**
- **Social Graph**: Connections, follows, friend suggestions ✅ **Implemented**
- **Governance**: DAO voting, proposals, community decisions 🚧 **Planned**
- **Monetization**: Token rewards, tips, creator payments 🚧 **Planned**

### Frontend
- **Framework**: React + TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: React Context
- **Routing**: React Router

### Infrastructure
- **Authentication**: Internet Identity (NFID)
- **Storage**: ICP On-chain Storage
- **Deployment**: ICP Mainnet
- **Development**: DFX SDK

## 🚀 Quick Start

**USE DFX 0.27.0**

### 🌿 Development Workflow

Before starting development, familiarize yourself with our git workflow:

```bash
# Create a new feature branch
just branch feature your-feature-name

# Make changes, then create PR
just pr "Your PR title" "Your PR description"
```

📖 **See [Git Workflow Guide](docs/GIT_WORKFLOW.md) for complete details**

### Option 1: Playground Development (Recommended)

1. **Setup the Project:**
   ```bash
   just setup
   ```

2. **Deploy to Playground:**
   ```bash
   dfx deploy --playground
   ```

3. **Get Your URLs:**
   ```bash
   just urls
   ```

4. **Access Your Application:**
   - Use the **Frontend URL** for normal browsing
   - Use the **Backend/Content Candid URLs** for API testing

> **💡 Pro Tip:** Playground deployment provides a shared, persistent environment perfect for development and testing.

### Option 2: GitHub Codespaces

1. **Open in Codespaces:**
   - Click the green "Code" button on this repository
   - Select "Create codespace on main"
   - Wait for the environment to load

2. **Setup the Project:**
   ```bash
   just setup
   ```

3. **Deploy to Local Network:**
   ```bash
   just deploy
   ```

4. **Get Your URLs:**
   ```bash
   just urls
   ```

5. **Access Your Application:**
   - Use the **Frontend URL** for normal browsing
   - Use the **Backend/Content Candid URLs** for API testing

> **💡 Pro Tip:** The devcontainer is pre-configured with all necessary tools including DFX, Node.js, and just. Port forwarding is automatically set up for seamless development.

### Option 3: Local Development

1. **Install Dependencies:**
   ```bash
   # Install just (task runner)
   curl -s https://just.systems/install.sh | bash -s -- --to /usr/local/bin
   
   # Install DFX
   sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
   
   # Install Node.js
   # Visit: https://nodejs.org/
   # Or run: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs
   ```

2. **Setup the Project:**
   ```bash
   just setup
   ```

3. **Deploy:**
   ```bash
   just deploy
   ```

## 📋 Available Commands

Run `just` to see all available commands:

```bash
just
```

### Key Commands:
- `just setup` - Initial project setup
- `just deploy` - Deploy all canisters
- `just test` - Run unit tests
- `just urls` - Show current canister URLs
- `just troubleshoot` - Diagnose deployment issues
- `just status` - Check project status

## 🧪 Testing

### Running Tests
```bash
# Run all unit tests
just test

# Run tests manually
chmod +x scripts/run-tests.sh
./scripts/run-tests.sh
```

### CI/CD Pipeline
This project includes a comprehensive GitHub Actions CI/CD pipeline that:
- Runs unit tests on every push and pull request
- Validates canister deployments
- Performs code quality checks
- Deploys preview environments for pull requests

See [CI_CD.md](docs/CI_CD.md) for detailed documentation.

## 📁 Project Structure

```
chainedsocial/
├── backend/          # Backend canister (Motoko)
│   ├── main.mo      # User management & authentication
│   └── types.mo     # Type definitions
├── content/          # Content canister (Motoko)
│   └── main.mo      # Posts, comments, media
├── socialgraph/      # Social Graph canister (Motoko)
│   └── main.mo      # Connections, follows, interactions
├── frontend/         # React frontend application
│   ├── src/
│   │   ├── components/
│   │   └── main.jsx
│   └── package.json
├── docs/            # Documentation
│   ├── README.md    # Documentation index
│   ├── BUILD.md     # Build instructions
│   ├── CI_CD.md     # CI/CD setup
│   └── LOGGING.md   # Enhanced logging guide
├── scripts/          # Utility scripts
├── justfile          # Task runner configuration
├── dfx.json          # DFX project configuration
└── README.md         # This file
```

## 📚 Documentation

For comprehensive documentation, see the [docs/](docs/) directory:

- **[Documentation Index](docs/README.md)** - Complete documentation overview
- **[Build Guide](docs/BUILD.md)** - Build and deployment instructions
- **[CI/CD Setup](docs/CI_CD.md)** - Continuous integration configuration
- **[Logging Guide](docs/LOGGING.md)** - Enhanced Pino logging setup

## 🏆 Current Features

### ✅ Implemented
- **User Authentication**: NFID login with persistent identities
- **Profile Management**: Username uniqueness, bio, persistent profiles
- **Content System**: Posts, comments, media uploads
- **Social Graph**: Follow/unfollow, connections, user interactions
- **Real-time UI**: Username availability checking, profile editing
- **Logout System**: Complete session management

### 🚧 In Development
- **Governance**: DAO voting and proposals
- **Monetization**: Token rewards and creator payments
- **NFT Integration**: Profile pictures and collectible posts
- **AI Discovery**: Intelligent content recommendations

## 🎯 WCHL25 Roadmap

### Phase 1: Foundation ✅ **COMPLETED**
- [x] User registration and authentication
- [x] Basic profile management
- [x] Simple posting functionality
- [x] Core UI components

### Phase 2: Social Features ✅ **COMPLETED**
- [x] Following/followers system
- [x] Comments and reactions
- [x] Content discovery feed
- [x] Real-time messaging (basic)

### Phase 3: Governance 🚧 **IN PROGRESS**
- [ ] DAO governance implementation
- [ ] Proposal creation and voting
- [ ] Community moderation tools
- [ ] Token distribution system

### Phase 4: Advanced Features 📋 **PLANNED**
- [ ] Creator monetization
- [ ] NFT integration
- [ ] AI-powered recommendations
- [ ] Performance optimization

## 🏆 Competitive Advantages

1. **True Decentralization**: 100% on-chain vs. hybrid solutions
2. **Infinite Scalability**: ICP's unique architecture allows unlimited growth
3. **No Gas Fees**: Users don't pay transaction costs
4. **Community Owned**: DAO governance ensures user interests come first
5. **Censorship Resistant**: Distributed storage prevents content removal
6. **Persistent Identities**: Users maintain their profiles across sessions
7. **Username Uniqueness**: Prevents duplicate usernames across the platform

## 🔧 Development

### Local Development Setup

1. **Start DFX:**
   ```bash
   dfx start --background
   ```

2. **Create Identity (Optional):**
   ```bash
   dfx identity new my-identity
   dfx identity use my-identity
   ```

3. **Deploy:**
   ```bash
   just deploy
   ```

### Mainnet Deployment

1. **Get Cycles:**
   ```bash
   just check-balance
   just convert-cycles
   ```

2. **Deploy to Mainnet:**
   ```bash
   dfx deploy --network ic
   ```

> **Note:** Mainnet deployment requires cycles. Learn more about [ICP cycles](https://internetcomputer.org/docs/building-apps/getting-started/tokens-and-cycles).

## 🌐 Understanding URLs

This project generates different types of URLs:

- **Frontend URL**: Your main web application (use for normal browsing)
- **Backend/Content Candid URLs**: API interfaces for testing canister functions

Run `just explain-urls` for detailed information about URL types.

## 🔧 Troubleshooting

### Common Issues:

1. **CanisterIdNotFound Errors:**
   ```bash
   just troubleshoot
   ```

2. **Port Forwarding Issues (Codespaces):**
   ```bash
   just codespaces-setup
   ```

3. **Build Errors:**
   ```bash
   just reset
   just setup
   just deploy
   ```

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌐 Links

- **Demo**: https://chainedsocial.icp0.io
- **Documentation**: https://docs.chainedsocial.network
- **Twitter**: https://twitter.com/chainedsocial
- **Discord**: https://discord.gg/chainedsocial
- **Telegram**: https://t.me/chainedsocial

## 📺 Videos

- **[ChainedSocial Demo](https://youtu.be/JiQCSyT3_HA)** - Watch our platform in action
- **[ChainedSocial Deployment and Walkthrough](https://youtu.be/N4btismZ5I0)** - Detailed feature overview and demonstration

## 🚀 Built for ICP WCHL25

This project is built for the World Computer Hacker League 2025 qualification round. It demonstrates the power of the Internet Computer Protocol for hosting complete, scalable social media platforms entirely on-chain.

## 📚 Resources

- [Internet Computer Documentation](https://internetcomputer.org/docs)
- [DFINITY Examples](https://github.com/dfinity/examples)
- [Motoko Language Guide](https://internetcomputer.org/docs/current/developer-docs/build/languages/motoko/)
- [Candid Interface Specification](https://internetcomputer.org/docs/current/developer-docs/build/candid/candid-intro)

---

**Own Your Voice, Control Your Data** - ChainedSocial
