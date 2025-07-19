import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";

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
}; 