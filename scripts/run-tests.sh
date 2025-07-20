#!/bin/bash

echo "🧪 Starting Unit Tests for ChainedSocial..."

# Deploy main canisters
echo "🚀 Deploying canisters..."
dfx deploy backend
dfx deploy socialgraph

# Get canister IDs
BACKEND_ID=$(dfx canister id backend)
SOCIALGRAPH_ID=$(dfx canister id socialgraph)

echo "📋 Canister IDs:"
echo "  Backend: $BACKEND_ID"
echo "  Social Graph: $SOCIALGRAPH_ID"

# Run backend tests
echo ""
echo "🧪 Running Backend Tests..."
BACKEND_RESULT=$(dfx canister call backend runAllTests)
echo "Backend Test Result: $BACKEND_RESULT"

# Run social graph tests
echo ""
echo "🧪 Running Social Graph Tests..."
SOCIALGRAPH_RESULT=$(dfx canister call socialgraph runAllTests)
echo "Social Graph Test Result: $SOCIALGRAPH_RESULT"

echo ""
echo "✅ All tests completed!"
echo ""
echo "📊 Summary:"
echo "  Backend: $BACKEND_RESULT"
echo "  Social Graph: $SOCIALGRAPH_RESULT" 