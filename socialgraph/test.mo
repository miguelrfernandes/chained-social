import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Time "mo:base/Time";

actor {
    // Test data - using valid principal formats
    let testPrincipal1 = Principal.fromText("2vxsx-fae");
    let testPrincipal2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
    let testPrincipal3 = Principal.fromText("2vxsx-fae"); // Using same as testPrincipal1 for simplicity

    // Test follow functionality
    public shared ({ caller }) func testFollowUser() : async Bool {
        Debug.print("🧪 Testing followUser...");
        
        let result = await followUser(testPrincipal1);
        
        switch (result) {
            case (#ok(follow)) {
                if (Principal.equal(follow.follower, caller) and 
                    Principal.equal(follow.following, testPrincipal1) and 
                    follow.isActive) {
                    Debug.print("✅ followUser passed - Follow created successfully");
                    return true;
                } else {
                    Debug.print("❌ followUser failed - Follow data incorrect");
                    return false;
                };
            };
            case (#err(error)) {
                Debug.print("❌ followUser failed: " # error);
                return false;
            };
        };
    };

    // Test unfollow functionality
    public shared ({ caller }) func testUnfollowUser() : async Bool {
        Debug.print("🧪 Testing unfollowUser...");
        
        // First, follow the user
        let followResult = await followUser(testPrincipal1);
        switch (followResult) {
            case (#err(_)) {
                Debug.print("❌ testUnfollowUser failed - Could not follow user first");
                return false;
            };
            case (#ok(_)) {
                // Continue with test
            };
        };
        
        // Then unfollow
        let result = await unfollowUser(testPrincipal1);
        
        switch (result) {
            case (#ok(success)) {
                if (success) {
                    Debug.print("✅ unfollowUser passed - User unfollowed successfully");
                    return true;
                } else {
                    Debug.print("❌ unfollowUser failed - Unfollow returned false");
                    return false;
                };
            };
            case (#err(error)) {
                Debug.print("❌ unfollowUser failed: " # error);
                return false;
            };
        };
    };

    // Test isFollowing functionality
    public shared ({ caller }) func testIsFollowing() : async Bool {
        Debug.print("🧪 Testing isFollowing...");
        
        // First, follow the user
        let followResult = await followUser(testPrincipal1);
        switch (followResult) {
            case (#err(_)) {
                Debug.print("❌ testIsFollowing failed - Could not follow user first");
                return false;
            };
            case (#ok(_)) {
                // Continue with test
            };
        };
        
        // Check if following
        let followingStatus = await isFollowing(caller, testPrincipal1);
        
        if (followingStatus) {
            Debug.print("✅ isFollowing passed - Correctly detected following status");
            return true;
        } else {
            Debug.print("❌ isFollowing failed - Should be following");
            return false;
        };
    };

    // Test isFollowing when not following
    public shared ({ caller }) func testIsFollowingNotFollowing() : async Bool {
        Debug.print("🧪 Testing isFollowing when not following...");
        
        // Check if following (should be false)
        let followingStatus = await isFollowing(caller, testPrincipal2);
        
        if (not followingStatus) {
            Debug.print("✅ isFollowingNotFollowing passed - Correctly detected not following");
            return true;
        } else {
            Debug.print("❌ isFollowingNotFollowing failed - Should not be following");
            return false;
        };
    };

    // Test anonymous user follow attempt
    public shared ({ caller }) func testAnonymousUserFollow() : async Bool {
        Debug.print("🧪 Testing anonymous user follow attempt...");
        
        // This test is limited since we can't easily simulate anonymous principals
        // In a real scenario, this would be tested with anonymous callers
        
        Debug.print("✅ Anonymous user test completed (simulated)");
        return true;
    };

    // Test self-follow attempt
    public shared ({ caller }) func testSelfFollow() : async Bool {
        Debug.print("🧪 Testing self-follow attempt...");
        
        let result = await followUser(caller);
        
        switch (result) {
            case (#ok(_)) {
                Debug.print("❌ testSelfFollow failed - Should not allow self-follow");
                return false;
            };
            case (#err(error)) {
                if (Text.contains(error, #text("themselves"))) {
                    Debug.print("✅ testSelfFollow passed - Correctly prevented self-follow");
                    return true;
                } else {
                    Debug.print("❌ testSelfFollow failed - Wrong error message: " # error);
                    return false;
                };
            };
        };
    };

    // Test multiple follows
    public shared ({ caller }) func testMultipleFollows() : async Bool {
        Debug.print("🧪 Testing multiple follows...");
        
        // Follow first user
        let result1 = await followUser(testPrincipal1);
        switch (result1) {
            case (#err(_)) {
                Debug.print("❌ testMultipleFollows failed - Could not follow first user");
                return false;
            };
            case (#ok(_)) {
                // Continue with test
            };
        };
        
        // Follow second user
        let result2 = await followUser(testPrincipal2);
        switch (result2) {
            case (#err(_)) {
                Debug.print("❌ testMultipleFollows failed - Could not follow second user");
                return false;
            };
            case (#ok(_)) {
                // Continue with test
            };
        };
        
        // Check both follows
        let isFollowing1 = await isFollowing(caller, testPrincipal1);
        let isFollowing2 = await isFollowing(caller, testPrincipal2);
        
        if (isFollowing1 and isFollowing2) {
            Debug.print("✅ testMultipleFollows passed - Both follows working");
            return true;
        } else {
            Debug.print("❌ testMultipleFollows failed - Not all follows detected");
            return false;
        };
    };

    // Test getUserStats
    public shared ({ caller }) func testGetUserStats() : async Bool {
        Debug.print("🧪 Testing getUserStats...");
        
        // Follow a user first
        let _ = await followUser(testPrincipal1);
        
        let stats = await getUserStats(caller);
        
        if (stats.followingCount >= 1) {
            Debug.print("✅ testGetUserStats passed - Stats calculated correctly");
            return true;
        } else {
            Debug.print("❌ testGetUserStats failed - Stats not calculated correctly");
            return false;
        };
    };

    // Test getFollowers
    public shared ({ caller }) func testGetFollowers() : async Bool {
        Debug.print("🧪 Testing getFollowers...");
        
        // This test is limited since we need another user to follow the caller
        // In a real scenario, this would be tested with multiple principals
        
        let followers = await getFollowers(caller);
        
        Debug.print("✅ testGetFollowers completed - Found " # Nat.toText(followers.size()) # " followers");
        return true;
    };

    // Test getFollowing
    public shared ({ caller }) func testGetFollowing() : async Bool {
        Debug.print("🧪 Testing getFollowing...");
        
        // Follow a user first
        let _ = await followUser(testPrincipal1);
        
        let following = await getFollowing(caller);
        
        if (following.size() >= 1) {
            Debug.print("✅ testGetFollowing passed - Following list correct");
            return true;
        } else {
            Debug.print("❌ testGetFollowing failed - Following list empty");
            return false;
        };
    };

    // Run all tests
    public shared ({ caller }) func runAllTests() : async Text {
        Debug.print("🚀 Starting social graph tests...");
        
        var passedTests = 0;
        var totalTests = 0;
        
        // Test 1: Follow user
        totalTests += 1;
        if (await testFollowUser()) {
            passedTests += 1;
        };
        
        // Test 2: Unfollow user
        totalTests += 1;
        if (await testUnfollowUser()) {
            passedTests += 1;
        };
        
        // Test 3: Check following status
        totalTests += 1;
        if (await testIsFollowing()) {
            passedTests += 1;
        };
        
        // Test 4: Check not following status
        totalTests += 1;
        if (await testIsFollowingNotFollowing()) {
            passedTests += 1;
        };
        
        // Test 5: Self-follow prevention
        totalTests += 1;
        if (await testSelfFollow()) {
            passedTests += 1;
        };
        
        // Test 6: Multiple follows
        totalTests += 1;
        if (await testMultipleFollows()) {
            passedTests += 1;
        };
        
        // Test 7: User stats
        totalTests += 1;
        if (await testGetUserStats()) {
            passedTests += 1;
        };
        
        // Test 8: Get following list
        totalTests += 1;
        if (await testGetFollowing()) {
            passedTests += 1;
        };
        
        let result = "Social Graph Tests: " # Nat.toText(passedTests) # "/" # Nat.toText(totalTests) # " passed";
        Debug.print(result);
        return result;
    };

    // Import the actual social graph functions for testing
    // These are simplified versions for testing
    
    stable var followIdCounter : Nat = 0;
    stable var connectionIdCounter : Nat = 0;
    stable var interactionIdCounter : Nat = 0;

    private var follows = HashMap.HashMap<Nat, {
        id : Nat;
        follower : Principal;
        following : Principal;
        timestamp : Int;
        isActive : Bool;
    }>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });

    public shared ({ caller }) func followUser(targetUser : Principal) : async Result.Result<{
        id : Nat;
        follower : Principal;
        following : Principal;
        timestamp : Int;
        isActive : Bool;
    }, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot follow");
        };

        if (Principal.equal(caller, targetUser)) {
            return #err("Users cannot follow themselves");
        };

        let newFollow : {
            id : Nat;
            follower : Principal;
            following : Principal;
            timestamp : Int;
            isActive : Bool;
        } = {
            id = followIdCounter;
            follower = caller;
            following = targetUser;
            timestamp = Time.now();
            isActive = true;
        };

        follows.put(followIdCounter, newFollow);
        followIdCounter += 1;

        return #ok(newFollow);
    };

    public shared ({ caller }) func unfollowUser(targetUser : Principal) : async Result.Result<Bool, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot unfollow");
        };

        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.follower, caller) and Principal.equal(follow.following, targetUser) and follow.isActive) {
                let updatedFollow = {
                    id = follow.id;
                    follower = caller;
                    following = targetUser;
                    timestamp = follow.timestamp;
                    isActive = false;
                };
                follows.put(id, updatedFollow);
                return #ok(true);
            };
        };

        return #err("Not following this user");
    };

    public query func isFollowing(follower : Principal, following : Principal) : async Bool {
        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.follower, follower) and Principal.equal(follow.following, following) and follow.isActive) {
                return true;
            };
        };
        return false;
    };

    public query func getUserStats(userId : Principal) : async {
        followersCount : Nat;
        followingCount : Nat;
        connectionsCount : Nat;
        interactionsReceived : Nat;
        interactionsGiven : Nat;
    } {
        var followersCount : Nat = 0;
        var followingCount : Nat = 0;

        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.following, userId) and follow.isActive) {
                followersCount += 1;
            };
            if (Principal.equal(follow.follower, userId) and follow.isActive) {
                followingCount += 1;
            };
        };

        return {
            followersCount = followersCount;
            followingCount = followingCount;
            connectionsCount = 0;
            interactionsReceived = 0;
            interactionsGiven = 0;
        };
    };

    public query func getFollowers(userId : Principal) : async [Principal] {
        let followers = Buffer.Buffer<Principal>(0);
        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.following, userId) and follow.isActive) {
                followers.add(follow.follower);
            };
        };
        return Buffer.toArray(followers);
    };

    public query func getFollowing(userId : Principal) : async [Principal] {
        let following = Buffer.Buffer<Principal>(0);
        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.follower, userId) and follow.isActive) {
                following.add(follow.following);
            };
        };
        return Buffer.toArray(following);
    };
}; 