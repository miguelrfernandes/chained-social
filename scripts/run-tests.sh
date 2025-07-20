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

# # Test backend canister functions
#           dfx canister call backend isUsernameAvailable '("test-user")' || echo "Username availability test completed"
          
#           # Test content canister functions
#           dfx canister call content getPostCount || echo "Post count test completed"
          
#           # Test social graph canister functions
#           dfx canister call socialgraph getUserStats '(principal "2vxsx-fae")' || echo "Social graph test completed"
          
#           # Test canister status
#           dfx canister status backend || echo "Backend status check completed"
#           dfx canister status content || echo "Content status check completed"
#           dfx canister status socialgraph || echo "Social graph status check completed"