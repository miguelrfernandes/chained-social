#!/bin/bash

# Exit on any error
set -e

echo "🧪 Starting Unit Tests for ChainedSocial..."

# Deploy main canisters
echo "🚀 Deploying canisters..."
dfx deploy backend
dfx deploy socialgraph
dfx deploy content

# Get canister IDs
BACKEND_ID=$(dfx canister id backend)
SOCIALGRAPH_ID=$(dfx canister id socialgraph)
CONTENT_ID=$(dfx canister id content)

echo "📋 Canister IDs:"
echo "  Backend: $BACKEND_ID"
echo "  Social Graph: $SOCIALGRAPH_ID"
echo "  Content: $CONTENT_ID"

# Initialize test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo ""
    echo "🧪 Running: $test_name"
    if eval "$test_command"; then
        echo "✅ $test_name: PASSED"
        ((TESTS_PASSED++))
    else
        echo "❌ $test_name: FAILED"
        ((TESTS_FAILED++))
    fi
}

# Run comprehensive unit tests
echo ""
echo "🧪 Running Comprehensive Unit Tests..."

# Run backend tests
run_test "Backend runAllTests" "dfx canister call backend runAllTests"

# Run social graph tests
run_test "Social Graph runAllTests" "dfx canister call socialgraph runAllTests"

# Test specific backend canister functions
run_test "Backend isUsernameAvailable" "dfx canister call backend isUsernameAvailable '(\"test-user\")'"

# Test content canister functions
run_test "Content getPostCount" "dfx canister call content getPostCount"

# Test social graph canister functions
run_test "Social Graph getUserStats" "dfx canister call socialgraph getUserStats '(principal \"2vxsx-fae\")'"

# Test canister status
run_test "Backend Status Check" "dfx canister status backend"
run_test "Content Status Check" "dfx canister status content"
run_test "Social Graph Status Check" "dfx canister status socialgraph"

echo ""
echo "✅ All tests completed!"
echo ""
echo "📊 Test Summary:"
echo "  ✅ Passed: $TESTS_PASSED"
echo "  ❌ Failed: $TESTS_FAILED"
echo "  📊 Total: $((TESTS_PASSED + TESTS_FAILED))"

# Exit with error code if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    echo ""
    echo "❌ Some tests failed. Please check the output above."
    exit 1
else
    echo ""
    echo "🎉 All tests passed successfully!"
    exit 0
fi 
