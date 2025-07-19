# Chained Social

A decentralized social media platform built on the Internet Computer (ICP). This project features a modular backend architecture with user management, content system, social graph, governance, and monetization canisters.

## Project Overview

Chained Social is a comprehensive social media platform that leverages the Internet Computer's capabilities to provide a truly decentralized social experience. The platform includes features for user authentication, content creation, social interactions, community governance, and creator monetization.

## 🚀 Quick Start

USE DFX 0.27.0

### Option 1: GitHub Codespaces (Recommended)

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

### Option 2: Local Development

1. **Install Dependencies:**
   ```bash
   # Install just (task runner)
   curl -s https://just.systems/install.sh | bash -s -- --to /usr/local/bin
   
   # Install DFX
   sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
   
   # Install ic-mops
   pnpm add -g ic-mops
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
- `just urls` - Show current canister URLs
- `just explain-urls` - Understand different URL types
- `just troubleshoot` - Diagnose deployment issues
- `just status` - Check project status

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

## 📁 Project Structure

```
chainedsocial/
├── backend/          # Backend canister (Motoko)
├── content/          # Content canister (Motoko)
├── frontend/         # React frontend application
├── scripts/          # Utility scripts
├── justfile          # Task runner configuration
├── dfx.json          # DFX project configuration
└── README.md         # This file
```

## 🏗️ Architecture

### Canisters (Backend Services)

- **Backend Canister**: Core application logic and user management
- **Content Canister**: Content storage and management
- **Frontend Canister**: Web application assets

### Frontend

- **React**: Modern UI framework
- **Vite**: Fast build tool
- **Tailwind CSS**: Utility-first CSS framework

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

## 🚧 Planned Features

### Backend Architecture (ICP Canisters)

This project will use a modular backend architecture on the Internet Computer:

- **User Management Canister:** Profile creation, authentication, and identity verification
- **Content System Canister:** Posts, comments, media uploads, and content moderation
- **Social Graph Canister:** Connections, follows, and social interactions
- **Governance Canister:** DAO voting, proposals, and community decisions
- **Monetization Canister:** Token rewards, creator payments, and tip system

**Current Status:** Basic canister structure with authentication integration planned.

## 📚 Resources

- [Internet Computer Documentation](https://internetcomputer.org/docs)
- [DFINITY Examples](https://github.com/dfinity/examples)
- [Motoko Language Guide](https://internetcomputer.org/docs/current/developer-docs/build/languages/motoko/)
- [Candid Interface Specification](https://internetcomputer.org/docs/current/developer-docs/build/candid/candid-intro)
