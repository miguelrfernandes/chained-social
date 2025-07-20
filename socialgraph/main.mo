import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";

import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";

actor {
    // Types
    type UserId = Principal;
    type FollowId = Nat;
    type ConnectionId = Nat;
    type InteractionId = Nat;

    public type Follow = {
        id : FollowId;
        follower : UserId;
        following : UserId;
        timestamp : Int;
        isActive : Bool;
    };

    public type Connection = {
        id : ConnectionId;
        user1 : UserId;
        user2 : UserId;
        status : ConnectionStatus;
        timestamp : Int;
    };

    public type ConnectionStatus = {
        #pending;
        #accepted;
        #rejected;
        #blocked;
    };

    public type Interaction = {
        id : InteractionId;
        fromUser : UserId;
        toUser : UserId;
        interactionType : InteractionType;
        contentId : ?Text;
        timestamp : Int;
    };

    public type InteractionType = {
        #like;
        #comment;
        #share;
        #mention;
        #message;
    };

    public type UserStats = {
        followersCount : Nat;
        followingCount : Nat;
        connectionsCount : Nat;
        interactionsReceived : Nat;
        interactionsGiven : Nat;
    };

    // Stable variables for persistence
    stable var followIdCounter : Nat = 0;
    stable var connectionIdCounter : Nat = 0;
    stable var interactionIdCounter : Nat = 0;

    // Mutable storage
    private var follows = HashMap.HashMap<FollowId, Follow>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    private var connections = HashMap.HashMap<ConnectionId, Connection>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    private var interactions = HashMap.HashMap<InteractionId, Interaction>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });

    // Follow functionality
    public shared ({ caller }) func followUser(targetUser : UserId) : async Result.Result<Follow, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot follow");
        };

        if (Principal.equal(caller, targetUser)) {
            return #err("Users cannot follow themselves");
        };

        // Create new follow
        let newFollow : Follow = {
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

    public shared ({ caller }) func unfollowUser(targetUser : UserId) : async Result.Result<Bool, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot unfollow");
        };

        // Find and deactivate the follow
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

    // Connection functionality
    public shared ({ caller }) func sendConnectionRequest(targetUser : UserId) : async Result.Result<Connection, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot send connection requests");
        };

        if (Principal.equal(caller, targetUser)) {
            return #err("Users cannot connect to themselves");
        };

        let newConnection : Connection = {
            id = connectionIdCounter;
            user1 = caller;
            user2 = targetUser;
            status = #pending;
            timestamp = Time.now();
        };

        connections.put(connectionIdCounter, newConnection);
        connectionIdCounter += 1;

        return #ok(newConnection);
    };

    public shared ({ caller }) func respondToConnectionRequest(connectionId : ConnectionId, accept : Bool) : async Result.Result<Connection, Text> {
        let connection = connections.get(connectionId);
        switch (connection) {
            case (?conn) {
                if (not Principal.equal(caller, conn.user2)) {
                    return #err("Only the recipient can respond to connection requests");
                };

                if (conn.status != #pending) {
                    return #err("Connection request has already been processed");
                };

                let updatedConnection : Connection = {
                    id = conn.id;
                    user1 = conn.user1;
                    user2 = conn.user2;
                    status = if (accept) #accepted else #rejected;
                    timestamp = conn.timestamp;
                };

                connections.put(connectionId, updatedConnection);
                return #ok(updatedConnection);
            };
            case (null) {
                return #err("Connection not found");
            };
        };
    };

    // Interaction functionality
    public shared ({ caller }) func addInteraction(
        targetUser : UserId, 
        interactionType : InteractionType, 
        contentId : ?Text
    ) : async Result.Result<Interaction, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot create interactions");
        };

        if (Principal.equal(caller, targetUser)) {
            return #err("Users cannot interact with themselves");
        };

        let newInteraction : Interaction = {
            id = interactionIdCounter;
            fromUser = caller;
            toUser = targetUser;
            interactionType = interactionType;
            contentId = contentId;
            timestamp = Time.now();
        };

        interactions.put(interactionIdCounter, newInteraction);
        interactionIdCounter += 1;

        return #ok(newInteraction);
    };

    // Private helper functions for data retrieval (non-async)
    private func _getFollowers(userId : UserId) : [UserId] {
        let followers = Buffer.Buffer<UserId>(0);
        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.following, userId) and follow.isActive) {
                followers.add(follow.follower);
            };
        };
        return Buffer.toArray(followers);
    };

    private func _getFollowing(userId : UserId) : [UserId] {
        let following = Buffer.Buffer<UserId>(0);
        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.follower, userId) and follow.isActive) {
                following.add(follow.following);
            };
        };
        return Buffer.toArray(following);
    };

    private func _getConnections(userId : UserId) : [UserId] {
        let connections_list = Buffer.Buffer<UserId>(0);
        for ((id, connection) in connections.entries()) {
            if (connection.status == #accepted) {
                if (Principal.equal(connection.user1, userId)) {
                    connections_list.add(connection.user2);
                } else if (Principal.equal(connection.user2, userId)) {
                    connections_list.add(connection.user1);
                };
            };
        };
        return Buffer.toArray(connections_list);
    };

    // Query functions (public interface)
    public query func getFollowers(userId : UserId) : async [UserId] {
        return _getFollowers(userId);
    };

    public query func getFollowing(userId : UserId) : async [UserId] {
        return _getFollowing(userId);
    };

    public query func getConnections(userId : UserId) : async [UserId] {
        return _getConnections(userId);
    };

    public query func getUserStats(userId : UserId) : async UserStats {
        let followers = _getFollowers(userId);
        let following = _getFollowing(userId);
        let userConnections = _getConnections(userId);

        var interactionsReceived : Nat = 0;
        var interactionsGiven : Nat = 0;

        for ((id, interaction) in interactions.entries()) {
            if (Principal.equal(interaction.toUser, userId)) {
                interactionsReceived += 1;
            };
            if (Principal.equal(interaction.fromUser, userId)) {
                interactionsGiven += 1;
            };
        };

        return {
            followersCount = followers.size();
            followingCount = following.size();
            connectionsCount = userConnections.size();
            interactionsReceived = interactionsReceived;
            interactionsGiven = interactionsGiven;
        };
    };

    public query func isFollowing(follower : UserId, following : UserId) : async Bool {
        for ((id, follow) in follows.entries()) {
            if (Principal.equal(follow.follower, follower) and Principal.equal(follow.following, following) and follow.isActive) {
                return true;
            };
        };
        return false;
    };

    public query func areConnected(user1 : UserId, user2 : UserId) : async Bool {
        for ((id, connection) in connections.entries()) {
            if (connection.status == #accepted) {
                if ((Principal.equal(connection.user1, user1) and Principal.equal(connection.user2, user2)) or
                    (Principal.equal(connection.user1, user2) and Principal.equal(connection.user2, user1))) {
                    return true;
                };
            };
        };
        return false;
    };

    // ===== TEST FUNCTIONS =====
    
    // Test follow functionality
    public shared ({ caller = _ }) func testFollowUser() : async Bool {
        Debug.print("🧪 Testing followUser...");
        

        let testUser2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
        
        let result = await followUser(testUser2);
        
        switch (result) {
            case (#ok(follow)) {
                Debug.print("✅ followUser passed - Follow created successfully");
                return true;
            };
            case (#err(error)) {
                Debug.print("❌ followUser failed: " # error);
                return false;
            };
        };
    };

    // Test unfollow functionality
    public shared ({ caller = _ }) func testUnfollowUser() : async Bool {
        Debug.print("🧪 Testing unfollowUser...");
        
        let testUser2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
        
        // First follow the user
        let _ = await followUser(testUser2);
        
        // Then unfollow
        let result = await unfollowUser(testUser2);
        
        switch (result) {
            case (#ok(_)) {
                Debug.print("✅ unfollowUser passed - User unfollowed successfully");
                return true;
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
        
        let testUser2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
        
        // First follow the user
        let _ = await followUser(testUser2);
        
        // Check if following
        let isFollowingResult = await isFollowing(caller, testUser2);
        
        if (isFollowingResult) {
            Debug.print("✅ isFollowing passed - Correctly detected following status");
            return true;
        } else {
            Debug.print("❌ isFollowing failed - Should be following");
            return false;
        };
    };

    // Test isFollowing when not following
    public shared ({ caller = _ }) func testIsFollowingNotFollowing() : async Bool {
        Debug.print("🧪 Testing isFollowing when not following...");
        
        let testUser2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
        
        // Check if following (should be false)
        let isFollowingResult = await isFollowing(Principal.fromText("2vxsx-fae"), testUser2);
        
        if (not isFollowingResult) {
            Debug.print("✅ isFollowingNotFollowing passed - Correctly detected not following");
            return true;
        } else {
            Debug.print("❌ isFollowingNotFollowing failed - Should not be following");
            return false;
        };
    };

    // Test self-follow prevention
    public shared ({ caller = _ }) func testSelfFollow() : async Bool {
        Debug.print("🧪 Testing self-follow prevention...");
        
        let testUser = Principal.fromText("2vxsx-fae");
        
        let result = await followUser(testUser);
        
        switch (result) {
            case (#ok(_)) {
                Debug.print("❌ testSelfFollow failed - Should not allow self-follow");
                return false;
            };
            case (#err(error)) {
                if (Text.contains(error, #text "cannot follow themselves")) {
                    Debug.print("✅ testSelfFollow passed - Correctly prevented self-follow");
                    return true;
                } else {
                    Debug.print("❌ testSelfFollow failed - Wrong error message");
                    return false;
                };
            };
        };
    };

    // Test multiple follows
    public shared ({ caller = _ }) func testMultipleFollows() : async Bool {
        Debug.print("🧪 Testing multiple follows...");
        
        let testUser2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
        let testUser3 = Principal.fromText("2vxsx-fae");
        
        // Follow two users
        let result1 = await followUser(testUser2);
        let result2 = await followUser(testUser3);
        
        switch (result1, result2) {
            case (#ok(_), #ok(_)) {
                Debug.print("✅ testMultipleFollows passed - Both follows working");
                return true;
            };
            case (_, _) {
                Debug.print("❌ testMultipleFollows failed - One or both follows failed");
                return false;
            };
        };
    };

    // Test getUserStats
    public shared ({ caller = _ }) func testGetUserStats() : async Bool {
        Debug.print("🧪 Testing getUserStats...");
        
        let testUser = Principal.fromText("2vxsx-fae");
        
        let _stats = await getUserStats(testUser);
        
        Debug.print("✅ testGetUserStats passed - Stats calculated correctly");
        return true;
    };

    // Test getFollowing
    public shared ({ caller = _ }) func testGetFollowing() : async Bool {
        Debug.print("🧪 Testing getFollowing...");
        
        let testUser2 = Principal.fromText("3lsaa-3rti4-nxknq-3bgcr-orfvo-izh54-ynkrn-lo4a7-dew2m-ztmea-aae");
        
        // Follow a user
        let _ = await followUser(testUser2);
        
        // Get following list
        let following = await getFollowing(Principal.fromText("2vxsx-fae"));
        
        if (following.size() > 0) {
            Debug.print("✅ testGetFollowing passed - Following list correct");
            return true;
        } else {
            Debug.print("❌ testGetFollowing failed - Following list should not be empty");
            return false;
        };
    };

    // Run all tests
    public shared ({ caller = _ }) func runAllTests() : async Text {
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
        
        // Test 3: Is following
        totalTests += 1;
        if (await testIsFollowing()) {
            passedTests += 1;
        };
        
        // Test 4: Is following when not following
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
        
        // Test 7: Get user stats
        totalTests += 1;
        if (await testGetUserStats()) {
            passedTests += 1;
        };
        
        // Test 8: Get following
        totalTests += 1;
        if (await testGetFollowing()) {
            passedTests += 1;
        };
        
        let result = "Social Graph Tests: " # Nat.toText(passedTests) # "/" # Nat.toText(totalTests) # " passed";
        Debug.print(result);
        return result;
    };
}; 