#!/bin/bash

echo "🌐 Current Canister URLs:"

# Check if we're in GitHub Codespaces
if [ -n "$CODESPACES" ]; then
    echo "Frontend: https://${CODESPACE_NAME}-4943.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/"
    echo "Backend: https://${CODESPACE_NAME}-4943.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/?canisterId=umunu-kh777-77774-qaaca-cai&id=$(dfx canister id backend)"
    echo "Content: https://${CODESPACE_NAME}-4943.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/?canisterId=umunu-kh777-77774-qaaca-cai&id=$(dfx canister id content)"
else
    echo "Frontend: http://$(dfx canister id frontend).localhost:4943/"
    echo "Backend: http://127.0.0.1:4943/?canisterId=umunu-kh777-77774-qaaca-cai&id=$(dfx canister id backend)"
    echo "Content: http://127.0.0.1:4943/?canisterId=umunu-kh777-77774-qaaca-cai&id=$(dfx canister id content)"
fi 