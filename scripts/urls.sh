#!/bin/bash

echo "🌐 Current Canister URLs:"

# Get current canister IDs
FRONTEND_ID=$(dfx canister id frontend 2>/dev/null || echo "not-deployed")
BACKEND_ID=$(dfx canister id backend 2>/dev/null || echo "not-deployed")
CONTENT_ID=$(dfx canister id content 2>/dev/null || echo "not-deployed")

# Check if we're in GitHub Codespaces
if [ -n "$CODESPACES" ]; then
    BASE_URL="https://${CODESPACE_NAME}-4943.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    echo "Frontend: ${BASE_URL}/"
    echo "Backend Candid: ${BASE_URL}/?canisterId=umunu-kh777-77774-qaaca-cai&id=${BACKEND_ID}"
    echo "Content Candid: ${BASE_URL}/?canisterId=umunu-kh777-77774-qaaca-cai&id=${CONTENT_ID}"
else
    echo "Frontend: http://${FRONTEND_ID}.localhost:4943/"
    echo "Backend Candid: http://127.0.0.1:4943/?canisterId=umunu-kh777-77774-qaaca-cai&id=${BACKEND_ID}"
    echo "Content Candid: http://127.0.0.1:4943/?canisterId=umunu-kh777-77774-qaaca-cai&id=${CONTENT_ID}"
fi

# Show deployment status
echo ""
echo "📊 Deployment Status:"
echo "Frontend: ${FRONTEND_ID}"
echo "Backend: ${BACKEND_ID}"
echo "Content: ${CONTENT_ID}"
echo ""
echo "💡 Notes:"
echo "- Frontend: Direct access to the web app"
echo "- Backend/Content Candid: API interface for testing canister functions" 