# 🌿 Git Workflow Guide for ChainedSocial

This guide outlines the proper git workflow for the ChainedSocial project, ensuring all changes go through pull requests and use descriptive branch names.

## 🚀 Quick Start

### Creating a New Feature Branch

Use the just command to create descriptive branches:

```bash
# Create a new feature branch
just branch feature user-authentication

# Create a bug fix branch
just branch fix login-validation

# Create a documentation branch
just branch docs api-documentation

# Create a refactoring branch
just branch refactor component-structure

# Create a test branch
just branch test unit-tests

# Create a maintenance branch
just branch chore dependency-updates
```

### Manual Branch Creation

If you prefer manual creation:

```bash
# Ensure you're on main and up to date
git checkout main
git pull origin main

# Create and switch to new branch
git checkout -b feature/descriptive-branch-name

# Make your changes, then push
git add .
git commit -m "feat: descriptive commit message"
git push origin feature/descriptive-branch-name
```

## 📋 Branch Naming Conventions

### Branch Types

- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test-related changes
- `chore/` - Maintenance tasks

### Naming Examples

✅ **Good branch names:**
- `feature/user-authentication`
- `fix/login-validation-error`
- `docs/api-endpoints`
- `refactor/auth-component`
- `test/user-login-flow`
- `chore/update-dependencies`

❌ **Avoid these:**
- `feature/new-feature`
- `fix/bug`
- `update`
- `changes`

## 🔄 Complete Workflow

### 1. Start New Work

```bash
# Create new branch
just branch feature your-feature-name

# Or manually
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

### 2. Make Changes

```bash
# Make your changes, then stage them
git add .

# Commit with descriptive message
git commit -m "feat: add user authentication system"
```

### 3. Push and Create PR

```bash
# Push to remote
git push origin feature/your-feature-name

# Create pull request at:
# https://github.com/miguelrfernandes/chained-social/pull/new/feature/your-feature-name
```

### 4. After PR is Merged

```bash
# Switch back to main
git checkout main

# Pull latest changes
git pull origin main

# Delete local feature branch
git branch -d feature/your-feature-name
```

## 🚫 Important Rules

### Never Push Directly to Main

The main branch is protected and requires pull requests. You cannot push directly:

```bash
# ❌ This will fail
git push origin main

# ✅ Use feature branches instead
git push origin feature/your-branch-name
```

### Always Use Descriptive Names

```bash
# ❌ Bad
git checkout -b feature/new-feature

# ✅ Good
git checkout -b feature/user-profile-management
```

### Write Good Commit Messages

```bash
# ❌ Bad
git commit -m "fix"

# ✅ Good
git commit -m "fix: resolve user authentication timeout issue"
```

## 🛠️ Available Commands

### Just Commands

```bash
# Create new branch
just branch <type> <description>

# Deploy project
just deploy

# Run tests
just test

# Check status
just status

# Show URLs
just urls

# Troubleshoot issues
just troubleshoot
```

### Git Commands

```bash
# Check current branch
git branch --show-current

# See all branches
git branch -a

# See commit history
git log --oneline -10

# See what's changed
git status
```

## 🔧 Troubleshooting

### If You're on the Wrong Branch

```bash
# Switch to main
git checkout main

# Create new branch from main
just branch feature your-feature-name
```

### If You Need to Update Your Branch

```bash
# Switch to main and pull latest
git checkout main
git pull origin main

# Switch back to your branch
git checkout feature/your-branch-name

# Rebase on main
git rebase main
```

### If You Made Changes on Main

```bash
# Stash your changes
git stash

# Create proper branch
just branch feature your-feature-name

# Apply your changes
git stash pop
```

## 📝 Commit Message Guidelines

Use conventional commit format:

```bash
# Format: <type>(<scope>): <description>

# Examples:
git commit -m "feat: add user authentication system"
git commit -m "fix(auth): resolve login timeout issue"
git commit -m "docs: update API documentation"
git commit -m "refactor(components): simplify auth flow"
git commit -m "test: add unit tests for user service"
git commit -m "chore: update dependencies"
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting changes
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance tasks

## 🎯 Best Practices

1. **Always create feature branches** - Never work directly on main
2. **Use descriptive names** - Make it clear what the branch is for
3. **Keep branches small** - One feature per branch
4. **Write good commit messages** - Be descriptive and use conventional format
5. **Create PRs early** - Even for work in progress
6. **Review your own PRs** - Before asking others to review
7. **Delete merged branches** - Keep the repository clean

## 🔗 Useful Links

- [Create Pull Request](https://github.com/miguelrfernandes/chained-social/pull/new)
- [Repository Rules](https://github.com/miguelrfernandes/chained-social/rules)
- [Project Issues](https://github.com/miguelrfernandes/chained-social/issues) 