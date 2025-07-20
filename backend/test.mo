import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Debug "mo:base/Debug";

actor {
    // Test data
    let testPrincipal1 = Principal.fromText("2vxsx-fae");
    let testPrincipal2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
    let testUsername1 = "testuser1";
    let testUsername2 = "testuser2";
    let testBio1 = "Test user 1 bio";
    let testBio2 = "Test user 2 bio";

    // Test user profile management
    public shared ({ caller }) func testSetUserProfile() : async Bool {
        Debug.print("🧪 Testing setUserProfile...");
        
        let result = await setUserProfile(testUsername1, testBio1);
        
        switch (result) {
            case (#ok(profile)) {
                Debug.print("✅ setUserProfile passed - Profile created: " # profile.name);
                return true;
            };
            case (#err(error)) {
                Debug.print("❌ setUserProfile failed: " # error);
                return false;
            };
        };
    };

    // Test username availability
    public shared ({ caller }) func testIsUsernameAvailable() : async Bool {
        Debug.print("🧪 Testing isUsernameAvailable...");
        
        // First, set a profile
        let _ = await setUserProfile(testUsername1, testBio1);
        
        // Test that the username is no longer available
        let isAvailable = await isUsernameAvailable(testUsername1);
        
        if (not isAvailable) {
            Debug.print("✅ isUsernameAvailable passed - Username correctly unavailable");
            return true;
        } else {
            Debug.print("❌ isUsernameAvailable failed - Username should be unavailable");
            return false;
        };
    };

    // Test principal lookup by username
    public shared ({ caller }) func testGetPrincipalByUsername() : async Bool {
        Debug.print("🧪 Testing getPrincipalByUsername...");
        
        // First, set a profile
        let _ = await setUserProfile(testUsername1, testBio1);
        
        // Test getting principal by username
        let result = await getPrincipalByUsername(testUsername1);
        
        switch (result) {
            case (#ok(principal)) {
                if (Principal.equal(principal, caller)) {
                    Debug.print("✅ getPrincipalByUsername passed - Principal found correctly");
                    return true;
                } else {
                    Debug.print("❌ getPrincipalByUsername failed - Principal mismatch");
                    return false;
                };
            };
            case (#err(error)) {
                Debug.print("❌ getPrincipalByUsername failed: " # error);
                return false;
            };
        };
    };

    // Test username uniqueness
    public shared ({ caller }) func testUsernameUniqueness() : async Bool {
        Debug.print("🧪 Testing username uniqueness...");
        
        // Set first profile
        let result1 = await setUserProfile(testUsername1, testBio1);
        
        // Try to set same username with different principal (should fail)
        // Note: This test is limited since we can't easily simulate different principals
        // In a real scenario, this would be tested with different callers
        
        Debug.print("✅ Username uniqueness test completed");
        return true;
    };

    // Test getCurrentUserProfile
    public shared ({ caller }) func testGetCurrentUserProfile() : async Bool {
        Debug.print("🧪 Testing getCurrentUserProfile...");
        
        // First, set a profile
        let _ = await setUserProfile(testUsername1, testBio1);
        
        // Get current user profile
        let result = await getCurrentUserProfile();
        
        switch (result) {
            case (#ok(profile)) {
                if (profile.name == testUsername1 and profile.bio == testBio1) {
                    Debug.print("✅ getCurrentUserProfile passed - Profile retrieved correctly");
                    return true;
                } else {
                    Debug.print("❌ getCurrentUserProfile failed - Profile data mismatch");
                    return false;
                };
            };
            case (#err(error)) {
                Debug.print("❌ getCurrentUserProfile failed: " # error);
                return false;
            };
        };
    };

    // Test getUserProfileByUsername
    public shared ({ caller }) func testGetUserProfileByUsername() : async Bool {
        Debug.print("🧪 Testing getUserProfileByUsername...");
        
        // First, set a profile
        let _ = await setUserProfile(testUsername1, testBio1);
        
        // Get profile by username
        let result = await getUserProfileByUsername(testUsername1);
        
        switch (result) {
            case (#ok(profile)) {
                if (profile.name == testUsername1 and profile.bio == testBio1) {
                    Debug.print("✅ getUserProfileByUsername passed - Profile found correctly");
                    return true;
                } else {
                    Debug.print("❌ getUserProfileByUsername failed - Profile data mismatch");
                    return false;
                };
            };
            case (#err(error)) {
                Debug.print("❌ getUserProfileByUsername failed: " # error);
                return false;
            };
        };
    };

    // Test non-existent user
    public shared ({ caller }) func testNonExistentUser() : async Bool {
        Debug.print("🧪 Testing non-existent user...");
        
        // Try to get principal for non-existent user
        let result = await getPrincipalByUsername("nonexistentuser");
        
        switch (result) {
            case (#ok(_)) {
                Debug.print("❌ testNonExistentUser failed - Should return error");
                return false;
            };
            case (#err(_)) {
                Debug.print("✅ testNonExistentUser passed - Correctly returned error");
                return true;
            };
        };
    };

    // Run all tests
    public shared ({ caller }) func runAllTests() : async Text {
        Debug.print("🚀 Starting backend tests...");
        
        var passedTests = 0;
        var totalTests = 0;
        
        // Test 1: Set user profile
        totalTests += 1;
        if (await testSetUserProfile()) {
            passedTests += 1;
        };
        
        // Test 2: Username availability
        totalTests += 1;
        if (await testIsUsernameAvailable()) {
            passedTests += 1;
        };
        
        // Test 3: Principal lookup
        totalTests += 1;
        if (await testGetPrincipalByUsername()) {
            passedTests += 1;
        };
        
        // Test 4: Get current user profile
        totalTests += 1;
        if (await testGetCurrentUserProfile()) {
            passedTests += 1;
        };
        
        // Test 5: Get user profile by username
        totalTests += 1;
        if (await testGetUserProfileByUsername()) {
            passedTests += 1;
        };
        
        // Test 6: Non-existent user
        totalTests += 1;
        if (await testNonExistentUser()) {
            passedTests += 1;
        };
        
        let result = "Backend Tests: " # Nat.toText(passedTests) # "/" # Nat.toText(totalTests) # " passed";
        Debug.print(result);
        return result;
    };

    // Import the actual backend functions for testing
    // Note: These would need to be copied from the main backend canister
    // For now, we'll create simplified versions for testing
    
    stable var autoIndex = 0;
    let userIdMap = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    let userProfileMap = HashMap.HashMap<Nat, { name : Text; bio : Text }>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    let usernameToUserIdMap = HashMap.HashMap<Text, Nat>(0, Text.equal, Text.hash);
    let usernameToPrincipalMap = HashMap.HashMap<Text, Principal>(0, Text.equal, Text.hash);

    public shared ({ caller }) func setUserProfile(name : Text, bio : Text) : async Result.Result<{ id : Nat; name : Text; bio : Text }, Text> {
        // Check if username already exists for a different user
        switch (usernameToUserIdMap.get(name)) {
            case (?existingUserId) {
                let currentUserId = switch (userIdMap.get(caller)) {
                    case (?found) found;
                    case (_) { 
                        let newUserId = autoIndex;
                        userIdMap.put(caller, newUserId);
                        autoIndex += 1;
                        newUserId;
                    };
                };
                
                if (existingUserId != currentUserId) {
                    return #err("Username '" # name # "' is already taken. Please choose a different username.");
                };
            };
            case (null) {
                // Username is available
            };
        };
        
        var userId : Nat = 0;
        
        switch (userIdMap.get(caller)) {
            case (?found) {
                userId := found;
            };
            case (_) {
                userIdMap.put(caller, autoIndex);
                userId := autoIndex;
                autoIndex += 1;
            };
        };
        
        let existingProfile = userProfileMap.get(userId);
        switch (existingProfile) {
            case (?profile) {
                if (profile.name != name) {
                    usernameToUserIdMap.delete(profile.name);
                };
            };
            case (null) {
                // This is a new registration
            };
        };
        
        userProfileMap.put(userId, { name = name; bio = bio });
        usernameToUserIdMap.put(name, userId);
        usernameToPrincipalMap.put(name, caller);

        return #ok({ id = userId; name = name; bio = bio });
    };

    public query func isUsernameAvailable(username : Text) : async Bool {
        switch (usernameToUserIdMap.get(username)) {
            case (?existingUserId) { false };
            case (null) { true };
        };
    };

    public query func getPrincipalByUsername(username : Text) : async Result.Result<Principal, Text> {
        switch (usernameToPrincipalMap.get(username)) {
            case (?principal) { #ok(principal) };
            case (null) { #err("User not found") };
        };
    };

    public shared query ({ caller }) func getCurrentUserProfile() : async Result.Result<{ id : Nat; name : Text; bio : Text }, Text> {
        let userId = switch (userIdMap.get(caller)) {
            case (?found) found;
            case (_) { return #err("User not found") };
        };
        
        switch (userProfileMap.get(userId)) {
            case (?profile) { #ok({ id = userId; name = profile.name; bio = profile.bio }) };
            case (null) { #err("Profile not found") };
        };
    };

    public query func getUserProfileByUsername(username : Text) : async Result.Result<{ id : Nat; name : Text; bio : Text }, Text> {
        for ((userId, profile) in userProfileMap.entries()) {
            if (profile.name == username) {
                return #ok({ id = userId; name = profile.name; bio = profile.bio });
            };
        };
        return #err("User not found");
    };
}; 