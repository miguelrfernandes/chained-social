import { useState } from "react";
import { NFID } from "@nfid/embed";
import { HttpAgent } from "@dfinity/agent";
import { AnonymousIdentity } from "@dfinity/agent";
import {
  canisterId,
  createActor,
} from "../../../src/declarations/backend";

function NfidLogin({ setBackendActor }) {
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [loginError, setLoginError] = useState(null);

  async function handleLogin() {
    setIsLoggingIn(true);
    setLoginError(null);
    
    try {
      // Environment detection
      const isLocal = window.location.hostname.includes('localhost') || 
                     window.location.hostname.includes('127.0.0.1');
      
      console.log(`🌍 Environment: ${isLocal ? 'Local' : 'Production'}`);
      
      let agent;
      let principal;
      
      if (isLocal) {
        // For local development, use anonymous identity to avoid delegation issues
        console.log("🔧 Using anonymous identity for local development");
        
        agent = new HttpAgent({ 
          identity: new AnonymousIdentity(),
          host: "http://localhost:4943",
          verifyQuerySignatures: false,
          rejectUnauthorized: false,
          callTimeout: 60000
        });
        
        // Fetch root key for local development
        console.log("🔄 Fetching local root key...");
        try {
          await agent.fetchRootKey();
          console.log("✅ Root key fetched successfully");
        } catch (rootKeyError) {
          console.error("❌ Root key fetch failed:", rootKeyError);
          throw new Error(`Local replica unavailable. Please run: dfx start --clean\n${rootKeyError.message}`);
        }
        
        // Test the connection
        console.log("🔄 Testing connection...");
        try {
          await agent.status();
          console.log("✅ Agent connection verified");
        } catch (statusError) {
          console.error("❌ Agent status check failed:", statusError);
          throw new Error(`Connection test failed: ${statusError.message}`);
        }
        
        principal = "Anonymous (Local Development)";
        
      } else {
        // For production, use NFID
        console.log("🚀 Using NFID for production");
        
        const nfidConfig = {
          application: {
            name: "Chained Social",
            logo: "https://taikai.azureedge.net/g85_fmDME2uOKEmFV0CfFmfcZQCmiDvIFknjOsWr8v8/rs:fit:350:0:0/aHR0cHM6Ly9zdG9yYWdlLmdvb2dsZWFwaXMuY29tL3RhaWthaS1zdG9yYWdlL2ltYWdlcy9iYTViMmVhMC04ZDUxLTExZWYtYTI3MS02NTA0MjI1OTI3NGJTcXVlcmUtMiAoMikucG5n",
          },
        };
        
        const nfid = await NFID.init(nfidConfig);
        console.log("✅ NFID initialized");

        const delegationIdentity = await nfid.getDelegation({
          maxTimeToLive: BigInt(8) * BigInt(3_600_000_000_000),
        });
        console.log("✅ Delegation acquired");

        agent = new HttpAgent({ 
          identity: delegationIdentity,
          host: "https://icp-api.io"
        });
        
        principal = delegationIdentity.getPrincipal().toText();
      }

      const backendActor = createActor(canisterId, { agent });
      
      console.log("✅ Login successful, Principal:", principal);
      setBackendActor(backendActor, principal);
      
    } catch (error) {
      console.error("❌ Login error:", error);
      
      // Provide specific guidance based on error type
      let userMessage = "Login failed";
      if (error.message.includes("certificate verification failed")) {
        userMessage = "Local development setup issue. Please restart dfx with: dfx start --clean";
      } else if (error.message.includes("Invalid delegation")) {
        userMessage = "Authentication service unavailable. Please try again or check your internet connection.";
      } else if (error.message.includes("fetchRootKey")) {
        userMessage = "Local replica not running. Please start dfx: dfx start --clean";
      } else if (error.message.includes("threshold signature")) {
        userMessage = "Bitcoin service integration issue. This is expected in local development.";
      }
      
      setLoginError(userMessage);
    } finally {
      setIsLoggingIn(false);
    }
  }

  return (
    <div>
      <button
        id="loginBtn"
        onClick={handleLogin}
        disabled={isLoggingIn}
        className="px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white border-none rounded-lg cursor-pointer shadow-sm transition-all duration-300 hover:from-blue-600 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
      >
        {isLoggingIn ? "🔄 Connecting..." : "Connect to start posting"}
      </button>
      
      {loginError && (
        <div className="absolute top-16 right-4 mt-2 p-3 bg-red-50 border border-red-200 rounded-lg shadow-lg z-50 max-w-xs">
          <p className="text-red-800 text-sm">❌ {loginError}</p>
          {loginError.includes("dfx start") && (
            <p className="text-red-600 text-xs mt-1">
              💡 Try running: <code className="bg-red-100 px-1 rounded">dfx start --clean</code>
            </p>
          )}
        </div>
      )}
    </div>
  );
}

export default NfidLogin;
