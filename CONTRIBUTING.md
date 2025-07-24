# Contributing to ChainedSocial

Thank you for your interest in contributing to ChainedSocial! This guide will help you get started with contributing to our decentralized social media platform built on the Internet Computer Protocol (ICP).

## 🌟 Project Overview

ChainedSocial is a fully decentralized social media platform where users own their data, control their content, and participate in platform governance. The project consists of:

- **Backend**: Motoko canisters running on ICP blockchain
- **Frontend**: React + TypeScript with Vite and Tailwind CSS
- **Authentication**: Internet Identity (NFID)
- **Storage**: On-chain ICP storage

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have the following installed:

- **Node.js**: >= 20.0.0 (check `package.json` engines field)
- **DFX SDK**: Version 0.27.0 (required)
- **Git**: For version control
- **Just**: Command runner (install via `cargo install just`)

### Installation

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/chained-social.git
   cd chained-social
   ```

3. **Install DFX** (if not already installed):
   ```bash
   DFX_VERSION=0.27.0 sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
   ```

4. **Install dependencies and deploy**:
   ```bash
   just deploy
   ```

   This command will:
   - Install frontend dependencies
   - Start DFX in background
   - Create and deploy all canisters
   - Build frontend assets
   - Generate type declarations

### Development Commands

We use `just` as our command runner. Here are the key commands:

```bash
# 🚀 Full deployment (install, build, deploy)
just deploy

# 🧹 Clean build artifacts and restart
just clean

# 🧪 Run unit tests
just test

# 🚀 Deploy to playground
just deploy-playground

# 📋 View all available commands
just --list
```

### Alternative NPM Commands

```bash
# Build all workspaces
npm run build

# Run development servers
npm run dev
```

## 📁 Project Structure

```
chained-social/
├── backend/           # User management canister (Motoko)
├── content/           # Content system canister (Motoko) 
├── socialgraph/       # Social connections canister (Motoko)
├── frontend/          # React + TypeScript frontend
│   ├── src/
│   │   ├── components/
│   │   ├── declarations/  # Auto-generated from canisters
│   │   └── ...
│   ├── package.json
│   └── ...
├── scripts/           # Utility scripts
├── docs/             # Documentation
├── .github/          # GitHub workflows and configurations
├── dfx.json          # DFX configuration
├── justfile          # Command runner recipes
└── package.json      # Root package configuration
```

## 🛠️ Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- **Backend changes**: Edit Motoko files in `backend/`, `content/`, or `socialgraph/`
- **Frontend changes**: Edit React components in `frontend/src/`

### 3. Test Your Changes

```bash
# Run unit tests
just test

# Deploy locally to test
just deploy
```

### 4. Code Quality

Ensure your code follows our standards:

- **Frontend**: Uses ESLint and Prettier (configured in `frontend/`)
- **Motoko**: Follow Motoko best practices
- **TypeScript**: Strict type checking enabled

### 5. Commit and Push

```bash
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name
```

### 6. Create a Pull Request

- Open a pull request against the `develop` branch
- Fill out the PR template
- Ensure CI/CD pipeline passes

## 🧪 Testing

### Running Tests

```bash
# Run all tests
just test

# Run frontend tests specifically
cd frontend && npm test
```

### Test Coverage

- Unit tests for Motoko canisters
- Frontend component tests
- Integration tests for canister interactions

## 📝 Code Style Guidelines

### Motoko (Backend)

- Use descriptive variable and function names
- Follow Motoko naming conventions (camelCase)
- Add type annotations for public functions
- Include documentation comments for public APIs

### TypeScript/React (Frontend)

- Use TypeScript strict mode
- Follow React hooks best practices
- Use functional components with hooks
- Implement proper error boundaries
- Follow the configured ESLint and Prettier rules

### General Guidelines

- Write clear, self-documenting code
- Add comments for complex logic
- Keep functions small and focused
- Use meaningful commit messages (follow conventional commits)

## 🚦 CI/CD Pipeline

Our GitHub Actions workflow includes:

- **Security scanning** with TruffleHog
- **Code quality checks** (linting, formatting)
- **Unit and integration tests**
- **Build verification**
- **Deployment to test environments**

All checks must pass before merging.

## 🐛 Reporting Issues

When reporting issues:

1. **Search existing issues** first
2. **Use the issue templates** provided
3. **Include steps to reproduce**
4. **Provide environment details** (DFX version, Node.js version, OS)
5. **Add relevant logs or screenshots**

## 💡 Feature Requests

We welcome feature requests! Please:

1. **Check the roadmap** in README.md
2. **Search existing feature requests**
3. **Use the feature request template**
4. **Explain the use case and benefits**

## 🤝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers get started
- Collaborate openly and transparently

## 🏗️ Architecture Guidelines

### Canister Design

- **backend**: User management, authentication, profiles
- **content**: Posts, comments, media uploads, moderation
- **socialgraph**: Connections, follows, friend suggestions

### State Management

- Use React Context for global state
- Keep canister state minimal and efficient
- Implement proper error handling

### Security Considerations

- Validate all inputs
- Implement proper access controls
- Use Internet Identity for authentication
- Follow ICP security best practices

## 📚 Resources

- [Internet Computer Documentation](https://internetcomputer.org/docs/)
- [Motoko Programming Language](https://internetcomputer.org/docs/current/motoko/intro/)
- [DFX SDK Documentation](https://internetcomputer.org/docs/current/developer-docs/setup/install/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## 🆘 Getting Help

- **GitHub Discussions**: For questions and discussions
- **Issues**: For bug reports and feature requests
- **Discord/Telegram**: Check README for community links

## 📄 License

By contributing to ChainedSocial, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to ChainedSocial! Together, we're building the future of decentralized social media. 🚀