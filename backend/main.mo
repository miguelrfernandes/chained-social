// import the custom types we have in Types.mo
import Types "types";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";

import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";

actor {
    stable var autoIndex = 0;
    let userIdMap = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    let userProfileMap = HashMap.HashMap<Nat, { name : Text; bio : Text }>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    let userResultsMap = HashMap.HashMap<Nat, [Text]>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    
    // Add reverse lookup for username uniqueness
    let usernameToUserIdMap = HashMap.HashMap<Text, Nat>(0, Text.equal, Text.hash);
    
    // Add reverse lookup for principal by username
    let usernameToPrincipalMap = HashMap.HashMap<Text, Principal>(0, Text.equal, Text.hash);
    
    public query func getUserProfile() : async Result.Result<{ id : Nat; name : Text; bio : Text }, Text> {
        return #ok({ id = 123; name = "test"; bio = "test bio" });
    };

    // Get current user's profile
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
        // Search through all user profiles to find one with matching username
        for ((userId, profile) in userProfileMap.entries()) {
            if (profile.name == username) {
                return #ok({ id = userId; name = profile.name; bio = profile.bio });
            };
        };
        return #err("User not found");
    };

    // Check if username is available
    public query func isUsernameAvailable(username : Text) : async Bool {
        switch (usernameToUserIdMap.get(username)) {
            case (?existingUserId) { false };
            case (null) { true };
        };
    };

    // Get all registered usernames (for debugging/testing)
    public query func getAllUsernames() : async [Text] {
        let usernames = Buffer.Buffer<Text>(0);
        for ((username, userId) in usernameToUserIdMap.entries()) {
            usernames.add(username);
        };
        return Buffer.toArray(usernames);
    };

    // Get principal by username for social graph functionality
    public query func getPrincipalByUsername(username : Text) : async Result.Result<Principal, Text> {
        switch (usernameToPrincipalMap.get(username)) {
            case (?principal) { #ok(principal) };
            case (null) { #err("User not found") };
        };
    };

    public shared ({ caller }) func setUserProfile(name : Text, bio : Text) : async Result.Result<{ id : Nat; name : Text; bio : Text }, Text> {
        // Debug logging
        let _callerText = Principal.toText(caller);
        let isAnonymous = Principal.isAnonymous(caller);
        
        // Check if username already exists for a different user
        switch (usernameToUserIdMap.get(name)) {
            case (?existingUserId) {
                // Check if this is the same user trying to update their profile
                let currentUserId = switch (userIdMap.get(caller)) {
                    case (?found) found;
                    case (_) { 
                        // Create new user ID for this principal
                        let newUserId = autoIndex;
                        userIdMap.put(caller, newUserId);
                        autoIndex += 1;
                        newUserId;
                    };
                };
                
                if (existingUserId != currentUserId) {
                    // Username taken by a different user
                    return #err("Username '" # name # "' is already taken. Please choose a different username.");
                };
            };
            case (null) {
                // Username is available
            };
        };
        
        // Get or create user ID for this principal
        var userId : Nat = 0;
        
        switch (userIdMap.get(caller)) {
            case (?found) {
                userId := found;
            };
            case (_) {
                // Create new user ID for this principal
                userIdMap.put(caller, autoIndex);
                userId := autoIndex;
                autoIndex += 1;
            };
        };
        
        // Check if this is a new registration or profile update
        let existingProfile = userProfileMap.get(userId);
        switch (existingProfile) {
            case (?profile) {
                // This is a profile update - check if username is changing
                if (profile.name != name) {
                    // Username is being changed, remove old username from tracking
                    usernameToUserIdMap.delete(profile.name);
                };
            };
            case (null) {
                // This is a new registration
            };
        };
        
        // Set profile name and bio
        userProfileMap.put(userId, { name = name; bio = bio });
        
        // Add username to reverse lookup map for uniqueness tracking
        usernameToUserIdMap.put(name, userId);
        
        // Add username to principal mapping for social graph functionality
        usernameToPrincipalMap.put(name, caller);

        return #ok({ id = userId; name = name; bio = bio });
    };

    public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        // Check if user already exists
        let userId = switch (userIdMap.get(caller)) {
            case (?found) found;
            case (_) { return #err("User not found") };
        };

        let inputResults = switch (userResultsMap.get(userId)) {
            case (?found) found;
            case (_) { [] };
        };

        let updatedResults = Array.append(inputResults, [result]);
        userResultsMap.put(userId, updatedResults);

        return #ok({ id = userId; results = updatedResults });
    };

    public query func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        return #ok({ id = 123; results = ["fake result111"] });
    };

    public func outcall_ai_model_for_sentiment_analysis(paragraph : Text) : async Result.Result<{ paragraph : Text; result : Text }, Text> {
        let host = "api-inference.huggingface.co";
        let path = "/models/cardiffnlp/twitter-roberta-base-sentiment-latest";

        let headers = [
            {
                name = "Authorization";
                value = "Bearer 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";
            },
            { name = "Content-Type"; value = "application/json" },
        ];

        let body_json : Text = "{ \"inputs\" : \" " # paragraph # "\" }";

        let text_response = await make_post_http_outcall(host, path, headers, body_json);

        // TODO
        // Install "serde" package and parse JSON
        // calculate highest sentiment and return it as a result

        return #ok({
            paragraph = paragraph;
            result = text_response;
        });
    };

    // NOTE: don't edit below this line

    // Function to transform the HTTP response
    // This function can't be private because it's shared with the IC management canister
    // but it's usage, is not meant to be exposed to the frontend
    public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
        let transformed : Types.CanisterHttpResponsePayload = {
            status = raw.response.status;
            body = raw.response.body;
            headers = [
                {
                    name = "Content-Security-Policy";
                    value = "default-src 'self' data: blob:; connect-src 'self' http://localhost:* https://* http://* data: blob:; frame-src 'self' https://* http://* data: blob:; script-src 'self' 'unsafe-eval' 'unsafe-inline' https://*; style-src 'self' 'unsafe-inline' https://* http://*; style-src-elem 'self' 'unsafe-inline' https://* http://*; font-src 'self' https://* http://* data:; img-src 'self' data: blob: https://* http://*;";
                },
                { name = "Referrer-Policy"; value = "strict-origin" },
                { name = "Permissions-Policy"; value = "geolocation=(self); publickey-credentials-get=(self 'https://nfid.one' 'https://identity.ic0.app')" },
                {
                    name = "Strict-Transport-Security";
                    value = "max-age=63072000";
                },
                { name = "X-Content-Type-Options"; value = "nosniff" },
            ];
        };
        transformed;
    };

    func make_post_http_outcall(host : Text, path : Text, headers : [Types.HttpHeader], body_json : Text) : async Text {
        //1. DECLARE IC MANAGEMENT CANISTER
        //We need this so we can use it to make the HTTP request
        let ic : Types.IC = actor ("aaaaa-aa");

        //2. SETUP ARGUMENTS FOR HTTP GET request
        // 2.1 Setup the URL and its query parameters
        let url = "https://" # host # path;

        // 2.2 prepare headers for the system http_request call
        let request_headers = [
            { name = "Host"; value = host # ":443" },
            { name = "User-Agent"; value = "hackerhouse_canister" },
        ];

        let merged_headers = Array.flatten<Types.HttpHeader>([request_headers, headers]);

        // 2.2.1 Transform context
        let transform_context : Types.TransformContext = {
            function = transform;
            context = Blob.fromArray([]);
        };

        // The request body is an array of [Nat8] (see Types.mo) so do the following:
        // 1. Write a JSON string
        // 2. Convert ?Text optional into a Blob, which is an intermediate representation before you cast it as an array of [Nat8]
        // 3. Convert the Blob into an array [Nat8]
        let request_body_as_Blob : Blob = Text.encodeUtf8(body_json);
        let request_body_as_nat8 : [Nat8] = Blob.toArray(request_body_as_Blob);

        // 2.3 The HTTP request
        let http_request : Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null; //optional for request
            headers = merged_headers;
            // note: type of `body` is ?[Nat8] so it is passed here as "?request_body_as_nat8" instead of "request_body_as_nat8"
            body = ?request_body_as_nat8;
            method = #post;
            transform = ?transform_context;
        };

        //3. ADD CYCLES TO PAY FOR HTTP REQUEST

        //The IC specification spec says, "Cycles to pay for the call must be explicitly transferred with the call"
        //IC management canister will make the HTTP request so it needs cycles
        //See: https://internetcomputer.org/docs/current/motoko/main/cycles

        //The way Cycles.add() works is that it adds those cycles to the next asynchronous call
        //"Function add(amount) indicates the additional amount of cycles to be transferred in the next remote call"
        //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request
        //Cycles.add(230_949_972_000);
        //let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);
        let http_response : Types.HttpResponsePayload = await (with cycles = 230_949_972_000) ic.http_request<system>(http_request);

        //5. DECODE THE RESPONSE

        //As per the type declarations in `src/Types.mo`, the BODY in the HTTP response
        //comes back as [Nat8s] (e.g. [2, 5, 12, 11, 23]). Type signature:

        //public type HttpResponsePayload = {
        //     status : Nat;
        //     headers : [HttpHeader];
        //     body : [Nat8];
        // };

        //We need to decode that [Nat8] array that is the body into readable text.
        //To do this, we:
        //  1. Convert the [Nat8] into a Blob
        //  2. Use Blob.decodeUtf8() method to convert the Blob to a ?Text optional
        //  3. We use a switch to explicitly call out both cases of decoding the Blob into ?Text
        let response_body : Blob = Blob.fromArray(http_response.body);
        let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        // 6. RETURN RESPONSE OF THE BODY
        return decoded_text;
    };

    // ===== TEST FUNCTIONS =====
    
    // Test user profile management
    public shared ({ caller }) func testSetUserProfile() : async Bool {
        Debug.print("🧪 Testing setUserProfile...");
        
        let testUsername = "testuser1";
        let testBio = "Test user 1 bio";
        
        let result = await setUserProfile(testUsername, testBio);
        
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
        
        let testUsername = "testuser1";
        let testBio = "Test user 1 bio";
        
        // First, set a profile
        let _ = await setUserProfile(testUsername, testBio);
        
        // Test that the username is no longer available
        let isAvailable = await isUsernameAvailable(testUsername);
        
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
        
        let testUsername = "testuser1";
        let testBio = "Test user 1 bio";
        
        // First, set a profile
        let _ = await setUserProfile(testUsername, testBio);
        
        // Test getting principal by username
        let result = await getPrincipalByUsername(testUsername);
        
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

    // Test getCurrentUserProfile
    public shared ({ caller }) func testGetCurrentUserProfile() : async Bool {
        Debug.print("🧪 Testing getCurrentUserProfile...");
        
        let testUsername = "testuser1";
        let testBio = "Test user 1 bio";
        
        // First, set a profile
        let _ = await setUserProfile(testUsername, testBio);
        
        // Get current user profile
        let result = await getCurrentUserProfile();
        
        switch (result) {
            case (#ok(profile)) {
                if (profile.name == testUsername and profile.bio == testBio) {
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
        
        let testUsername = "testuser1";
        let testBio = "Test user 1 bio";
        
        // First, set a profile
        let _ = await setUserProfile(testUsername, testBio);
        
        // Get profile by username
        let result = await getUserProfileByUsername(testUsername);
        
        switch (result) {
            case (#ok(profile)) {
                if (profile.name == testUsername and profile.bio == testBio) {
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
};
