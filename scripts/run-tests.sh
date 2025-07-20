#!/bin/bash

echo "🧪 Starting Unit Tests for ChainedSocial..."

# Deploy test canisters
echo "🚀 Deploying test canisters..."
dfx deploy backend-test
dfx deploy socialgraph-test

# Get canister IDs
BACKEND_TEST_ID=$(dfx canister id backend-test)
SOCIALGRAPH_TEST_ID=$(dfx canister id socialgraph-test)

echo "📋 Test Canister IDs:"
echo "  Backend Test: $BACKEND_TEST_ID"
echo "  Social Graph Test: $SOCIALGRAPH_TEST_ID"

# Run backend tests
echo ""
echo "🧪 Running Backend Tests..."
BACKEND_RESULT=$(dfx canister call backend-test runAllTests)
echo "Backend Test Result: $BACKEND_RESULT"

# Run social graph tests
echo ""
echo "🧪 Running Social Graph Tests..."
SOCIALGRAPH_RESULT=$(dfx canister call socialgraph-test runAllTests)
echo "Social Graph Test Result: $SOCIALGRAPH_RESULT"

echo ""
echo "✅ All tests completed!"
echo ""
echo "📊 Summary:"
echo "  Backend: $BACKEND_RESULT"
echo "  Social Graph: $SOCIALGRAPH_RESULT" 