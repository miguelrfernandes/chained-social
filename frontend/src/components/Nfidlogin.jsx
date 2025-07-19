import { useState } from "react";
import { NFID } from "@nfid/embed";
import { HttpAgent } from "@dfinity/agent";
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
      const nfid = await NFID.init({
        application: {
          name: "Chained Social",
          logo: "https://taikai.azureedge.net/g85_fmDME2uOKEmFV0CfFmfcZQCmiDvIFknjOsWr8v8/rs:fit:350:0:0/aHR0cHM6Ly9zdG9yYWdlLmdvb2dsZWFwaXMuY29tL3RhaWthaS1zdG9yYWdlL2ltYWdlcy9iYTViMmVhMC04ZDUxLTExZWYtYTI3MS02NTA0MjI1OTI3NGJTcXVlcmUtMiAoMikucG5n",
        },
      });

      const delegationIdentity = await nfid.getDelegation({
        // Only for custom domain
        derivationOrigin: undefined,

        // 8 hours in nanoseconds
        maxTimeToLive: BigInt(8) * BigInt(3_600_000_000_000),
      });

      const agent = new HttpAgent({ identity: delegationIdentity });
      if (process.env.DFX_NETWORK === "local") {
        agent.fetchRootKey();
      }

      const backendActor = createActor(canisterId, { agent });
      const principal = delegationIdentity.getPrincipal().toText();
      
      // Call the parent's setBackendActor function with both actor and principal
      setBackendActor(backendActor, principal);
      
    } catch (error) {
      console.error("Login error:", error);
      setLoginError(error.message || "Login failed");
    } finally {
      setIsLoggingIn(false);
    }
  }

  return (
    <div className="text-center mb-6">
      <button
        id="loginBtn"
        onClick={handleLogin}
        disabled={isLoggingIn}
        className="px-6 py-3 text-lg bg-green-500 text-white border-none rounded-lg cursor-pointer shadow-lg transition-all duration-300 hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {isLoggingIn ? "🔄 Logging in..." : "🚀 Login with Gmail (powered by NFID)"}
      </button>
      
      {loginError && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-red-800 text-sm">❌ Login error: {loginError}</p>
        </div>
      )}
    </div>
  );
}

export default NfidLogin;
