import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Time "mo:base/Time";
import Iter "mo:base/Iter";

actor {
    stable var postIndex = 0;
    
    // Data structures
    public type Post = {
        id : Nat;
        author : Principal;
        authorName : Text;
        content : Text;
        timestamp : Int;
        likes : Nat;
        comments : [Comment];
    };

    public type Comment = {
        id : Nat;
        author : Principal;
        authorName : Text;
        content : Text;
        timestamp : Int;
    };

    public type CreatePostRequest = {
        content : Text;
        authorName : Text;
    };

    public type CreateCommentRequest = {
        postId : Nat;
        content : Text;
        authorName : Text;
    };

    // Storage
    let posts = HashMap.HashMap<Nat, Post>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    let userPosts = HashMap.HashMap<Principal, [Nat]>(0, Principal.equal, Principal.hash);

    // Create a new post
    public shared ({ caller }) func createPost(request : CreatePostRequest) : async Result.Result<Post, Text> {
        if (Text.size(request.content) == 0) {
            return #err("Post content cannot be empty");
        };

        if (Text.size(request.content) > 1000) {
            return #err("Post content too long (max 1000 characters)");
        };

        let postId = postIndex;
        postIndex += 1;

        let post : Post = {
            id = postId;
            author = caller;
            authorName = request.authorName;
            content = request.content;
            timestamp = Time.now();
            likes = 0;
            comments = [];
        };

        posts.put(postId, post);

        // Add post to user's posts list
        let userPostIds = switch (userPosts.get(caller)) {
            case (?existing) Array.append(existing, [postId]);
            case (_) [postId];
        };
        userPosts.put(caller, userPostIds);

        return #ok(post);
    };

    // Get a specific post by ID
    public query func getPost(postId : Nat) : async Result.Result<Post, Text> {
        switch (posts.get(postId)) {
            case (?post) #ok(post);
            case (_) #err("Post not found");
        };
    };

    // Get all posts (paginated)
    public query func getPosts(limit : Nat, offset : Nat) : async Result.Result<[Post], Text> {
        let allPosts = Iter.toArray<Post>(posts.vals());
        
        // Sort by timestamp (newest first)
        let sortedPosts = Array.sort<Post>(allPosts, func(a : Post, b : Post) : { #less; #equal; #greater } {
            if (a.timestamp > b.timestamp) { #less } else if (a.timestamp < b.timestamp) { #greater } else { #equal }
        });

        // Apply pagination
        let startIndex = offset;
        let endIndex = Nat.min(startIndex + limit, Array.size(sortedPosts));
        
        if (startIndex >= Array.size(sortedPosts)) {
            return #ok([]);
        };

        // Create paginated array manually
        let paginatedSize = endIndex - startIndex;
        let paginatedPosts = Array.init<Post>(paginatedSize, {
            id = 0;
            author = Principal.fromText("2vxsx-fae");
            authorName = "";
            content = "";
            timestamp = 0;
            likes = 0;
            comments = [];
        });
        
        var i = 0;
        while (i < paginatedSize) {
            paginatedPosts[i] := sortedPosts[startIndex + i];
            i += 1;
        };
        
        return #ok(Array.freeze(paginatedPosts));
    };

    // Get posts by a specific user
    public query func getUserPosts(user : Principal, limit : Nat, offset : Nat) : async Result.Result<[Post], Text> {
        switch (userPosts.get(user)) {
            case (?userPostIds) {
                let userPostsArray = Array.map<Nat, Post>(userPostIds, func(postId : Nat) : Post {
                    switch (posts.get(postId)) {
                        case (?post) post;
                        case (_) {
                            // Return a placeholder post if the actual post is not found
                            {
                                id = postId;
                                author = user;
                                authorName = "Unknown";
                                content = "Post not found";
                                timestamp = 0;
                                likes = 0;
                                comments = [];
                            }
                        };
                    }
                });

                // Sort by timestamp (newest first)
                let sortedPosts = Array.sort<Post>(userPostsArray, func(a : Post, b : Post) : { #less; #equal; #greater } {
                    if (a.timestamp > b.timestamp) { #less } else if (a.timestamp < b.timestamp) { #greater } else { #equal }
                });

                // Apply pagination
                let startIndex = offset;
                let endIndex = Nat.min(startIndex + limit, Array.size(sortedPosts));
                
                if (startIndex >= Array.size(sortedPosts)) {
                    return #ok([]);
                };

                // Create paginated array manually
                let paginatedSize = endIndex - startIndex;
                let paginatedPosts = Array.init<Post>(paginatedSize, {
                    id = 0;
                    author = Principal.fromText("2vxsx-fae");
                    authorName = "";
                    content = "";
                    timestamp = 0;
                    likes = 0;
                    comments = [];
                });
                
                var i = 0;
                while (i < paginatedSize) {
                    paginatedPosts[i] := sortedPosts[startIndex + i];
                    i += 1;
                };
                
                return #ok(Array.freeze(paginatedPosts));
            };
            case (_) #ok([]);
        };
    };

    // Like a post
    public shared ({ caller = _ }) func likePost(postId : Nat) : async Result.Result<Post, Text> {
        switch (posts.get(postId)) {
            case (?post) {
                let updatedPost : Post = {
                    id = post.id;
                    author = post.author;
                    authorName = post.authorName;
                    content = post.content;
                    timestamp = post.timestamp;
                    likes = post.likes + 1;
                    comments = post.comments;
                };
                posts.put(postId, updatedPost);
                return #ok(updatedPost);
            };
            case (_) #err("Post not found");
        };
    };

    // Add a comment to a post
    public shared ({ caller }) func addComment(request : CreateCommentRequest) : async Result.Result<Post, Text> {
        if (Text.size(request.content) == 0) {
            return #err("Comment content cannot be empty");
        };

        if (Text.size(request.content) > 500) {
            return #err("Comment content too long (max 500 characters)");
        };

        switch (posts.get(request.postId)) {
            case (?post) {
                let comment : Comment = {
                    id = Array.size(post.comments);
                    author = caller;
                    authorName = request.authorName;
                    content = request.content;
                    timestamp = Time.now();
                };

                let updatedComments = Array.append(post.comments, [comment]);
                let updatedPost : Post = {
                    id = post.id;
                    author = post.author;
                    authorName = post.authorName;
                    content = post.content;
                    timestamp = post.timestamp;
                    likes = post.likes;
                    comments = updatedComments;
                };

                posts.put(request.postId, updatedPost);
                return #ok(updatedPost);
            };
            case (_) #err("Post not found");
        };
    };

    // Get total number of posts
    public query func getPostCount() : async Nat {
        posts.size();
    };
}; 