import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";

actor {
    // Types
    public type MessageId = Nat;
    public type ConversationId = Nat;
    public type UserId = Principal;
    public type Timestamp = Int;

    public type Message = {
        id : MessageId;
        conversationId : ConversationId;
        sender : UserId;
        senderName : Text;
        content : Text;
        timestamp : Timestamp;
        messageType : MessageType;
        isRead : Bool;
        isEdited : Bool;
        editedAt : ?Timestamp;
        replyTo : ?MessageId;
        attachments : [Attachment];
    };

    public type MessageType = {
        #text;
        #image;
        #file;
        #system;
    };

    public type Attachment = {
        id : Text;
        filename : Text;
        fileType : Text;
        fileSize : Nat;
        url : Text;
    };

    public type Conversation = {
        id : ConversationId;
        participants : [UserId];
        participantNames : [Text];
        createdAt : Timestamp;
        lastMessageAt : Timestamp;
        lastMessage : ?Text;
        isGroup : Bool;
        title : ?Text;
        createdBy : UserId;
        isActive : Bool;
        unreadCounts : [(UserId, Nat)];
    };

    public type PrivacySettings = {
        userId : UserId;
        allowMessagesFrom : MessagePrivacy;
        allowGroupInvites : Bool;
        showOnlineStatus : Bool;
        showReadReceipts : Bool;
    };

    public type MessagePrivacy = {
        #everyone;
        #followersOnly;
        #connectionsOnly;
        #nobody;
    };

    public type CreateMessageRequest = {
        conversationId : ConversationId;
        content : Text;
        messageType : MessageType;
        replyTo : ?MessageId;
        attachments : [Attachment];
    };

    public type CreateConversationRequest = {
        participants : [UserId];
        participantNames : [Text];
        title : ?Text;
        isGroup : Bool;
        initialMessage : ?Text;
    };

    public type MessageReadReceipt = {
        messageId : MessageId;
        userId : UserId;
        readAt : Timestamp;
    };

    // Stable variables
    stable var messageIdCounter : Nat = 0;
    stable var conversationIdCounter : Nat = 0;

    // Storage
    private var messages = HashMap.HashMap<MessageId, Message>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    private var conversations = HashMap.HashMap<ConversationId, Conversation>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    private var userConversations = HashMap.HashMap<UserId, [ConversationId]>(0, Principal.equal, Principal.hash);
    private var conversationMessages = HashMap.HashMap<ConversationId, [MessageId]>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });
    private var privacySettings = HashMap.HashMap<UserId, PrivacySettings>(0, Principal.equal, Principal.hash);
    private var messageReadReceipts = HashMap.HashMap<MessageId, [MessageReadReceipt]>(0, Nat.equal, func(n : Nat) : Nat32 { Nat32.fromNat(n) });

    // Create a new conversation
    public shared ({ caller }) func createConversation(request : CreateConversationRequest) : async Result.Result<Conversation, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot create conversations");
        };

        // Validate participants
        if (Array.size(request.participants) == 0) {
            return #err("Conversation must have at least one participant");
        };

        // Check if caller is included in participants
        let callerIncluded = Array.find<UserId>(request.participants, func(p : UserId) : Bool {
            Principal.equal(p, caller)
        });

        let allParticipants = switch (callerIncluded) {
            case (?_) request.participants;
            case (null) Array.append(request.participants, [caller]);
        };

        let allParticipantNames = switch (callerIncluded) {
            case (?_) request.participantNames;
            case (null) Array.append(request.participantNames, ["Unknown"]);
        };

        // For non-group conversations, limit to 2 participants
        if (not request.isGroup and Array.size(allParticipants) > 2) {
            return #err("Direct conversations can only have 2 participants");
        };

        // Check if direct conversation already exists
        if (not request.isGroup) {
            let existingConv = findExistingDirectConversation(allParticipants);
            switch (existingConv) {
                case (?conv) { return #ok(conv) };
                case (null) {};
            };
        };

        let conversationId = conversationIdCounter;
        conversationIdCounter += 1;

        let conversation : Conversation = {
            id = conversationId;
            participants = allParticipants;
            participantNames = allParticipantNames;
            createdAt = Time.now();
            lastMessageAt = Time.now();
            lastMessage = request.initialMessage;
            isGroup = request.isGroup;
            title = request.title;
            createdBy = caller;
            isActive = true;
            unreadCounts = Array.map<UserId, (UserId, Nat)>(allParticipants, func(p : UserId) : (UserId, Nat) { (p, 0) });
        };

        conversations.put(conversationId, conversation);

        // Update user conversations for all participants
        for (participant in allParticipants.vals()) {
            let userConvs = switch (userConversations.get(participant)) {
                case (?existing) Array.append(existing, [conversationId]);
                case (null) [conversationId];
            };
            userConversations.put(participant, userConvs);
        };

        // Create initial message if provided
        switch (request.initialMessage) {
            case (?content) {
                ignore await sendMessage({
                    conversationId = conversationId;
                    content = content;
                    messageType = #text;
                    replyTo = null;
                    attachments = [];
                });
            };
            case (null) {};
        };

        return #ok(conversation);
    };

    // Send a message
    public shared ({ caller }) func sendMessage(request : CreateMessageRequest) : async Result.Result<Message, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot send messages");
        };

        // Validate conversation exists and user is participant
        let conversation = switch (conversations.get(request.conversationId)) {
            case (?conv) conv;
            case (null) { return #err("Conversation not found") };
        };

        let isParticipant = Array.find<UserId>(conversation.participants, func(p : UserId) : Bool {
            Principal.equal(p, caller)
        });

        switch (isParticipant) {
            case (null) { return #err("User is not a participant in this conversation") };
            case (?_) {};
        };

        // Validate content
        if (Text.size(request.content) == 0 and Array.size(request.attachments) == 0) {
            return #err("Message must have content or attachments");
        };

        if (Text.size(request.content) > 2000) {
            return #err("Message content too long (max 2000 characters)");
        };

        let messageId = messageIdCounter;
        messageIdCounter += 1;

        let message : Message = {
            id = messageId;
            conversationId = request.conversationId;
            sender = caller;
            senderName = getSenderName(caller, conversation.participants, conversation.participantNames);
            content = request.content;
            timestamp = Time.now();
            messageType = request.messageType;
            isRead = false;
            isEdited = false;
            editedAt = null;
            replyTo = request.replyTo;
            attachments = request.attachments;
        };

        messages.put(messageId, message);

        // Update conversation messages
        let convMessages = switch (conversationMessages.get(request.conversationId)) {
            case (?existing) Array.append(existing, [messageId]);
            case (null) [messageId];
        };
        conversationMessages.put(request.conversationId, convMessages);

        // Update conversation last message info
        let updatedConversation : Conversation = {
            id = conversation.id;
            participants = conversation.participants;
            participantNames = conversation.participantNames;
            createdAt = conversation.createdAt;
            lastMessageAt = Time.now();
            lastMessage = ?request.content;
            isGroup = conversation.isGroup;
            title = conversation.title;
            createdBy = conversation.createdBy;
            isActive = conversation.isActive;
            unreadCounts = updateUnreadCounts(conversation.unreadCounts, conversation.participants, caller);
        };
        conversations.put(request.conversationId, updatedConversation);

        return #ok(message);
    };

    // Get user's conversations
    public shared query ({ caller }) func getUserConversations() : async Result.Result<[Conversation], Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot access conversations");
        };

        let userConvIds = switch (userConversations.get(caller)) {
            case (?convIds) convIds;
            case (null) [];
        };

        let userConvs = Buffer.Buffer<Conversation>(Array.size(userConvIds));
        
        for (convId in userConvIds.vals()) {
            switch (conversations.get(convId)) {
                case (?conv) {
                    if (conv.isActive) {
                        userConvs.add(conv);
                    };
                };
                case (null) {};
            };
        };

        // Sort by last message timestamp (newest first)
        let sortedConvs = Array.sort<Conversation>(Buffer.toArray(userConvs), func(a : Conversation, b : Conversation) : { #less; #equal; #greater } {
            if (a.lastMessageAt > b.lastMessageAt) { #less } else if (a.lastMessageAt < b.lastMessageAt) { #greater } else { #equal }
        });

        return #ok(sortedConvs);
    };

    // Get messages from a conversation
    public shared query ({ caller }) func getConversationMessages(conversationId : ConversationId, limit : Nat, offset : Nat) : async Result.Result<[Message], Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot access messages");
        };

        // Validate conversation exists and user is participant
        let conversation = switch (conversations.get(conversationId)) {
            case (?conv) conv;
            case (null) { return #err("Conversation not found") };
        };

        let isParticipant = Array.find<UserId>(conversation.participants, func(p : UserId) : Bool {
            Principal.equal(p, caller)
        });

        switch (isParticipant) {
            case (null) { return #err("User is not a participant in this conversation") };
            case (?_) {};
        };

        let messageIds = switch (conversationMessages.get(conversationId)) {
            case (?ids) ids;
            case (null) [];
        };

        // Get messages and sort by timestamp (newest first)
        let convMessages = Buffer.Buffer<Message>(Array.size(messageIds));
        
        for (messageId in messageIds.vals()) {
            switch (messages.get(messageId)) {
                case (?message) convMessages.add(message);
                case (null) {};
            };
        };

        let sortedMessages = Array.sort<Message>(Buffer.toArray(convMessages), func(a : Message, b : Message) : { #less; #equal; #greater } {
            if (a.timestamp > b.timestamp) { #less } else if (a.timestamp < b.timestamp) { #greater } else { #equal }
        });

        // Apply pagination
        let startIndex = offset;
        let endIndex = Nat.min(startIndex + limit, Array.size(sortedMessages));
        
        if (startIndex >= Array.size(sortedMessages)) {
            return #ok([]);
        };

        let paginatedMessages = Array.tabulate<Message>(endIndex - startIndex, func(i : Nat) : Message {
            sortedMessages[startIndex + i]
        });

        return #ok(paginatedMessages);
    };

    // Mark message as read
    public shared ({ caller }) func markMessageAsRead(messageId : MessageId) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot mark messages as read");
        };

        let message = switch (messages.get(messageId)) {
            case (?msg) msg;
            case (null) { return #err("Message not found") };
        };

        // Check if user is participant in the conversation
        let conversation = switch (conversations.get(message.conversationId)) {
            case (?conv) conv;
            case (null) { return #err("Conversation not found") };
        };

        let isParticipant = Array.find<UserId>(conversation.participants, func(p : UserId) : Bool {
            Principal.equal(p, caller)
        });

        switch (isParticipant) {
            case (null) { return #err("User is not a participant in this conversation") };
            case (?_) {};
        };

        // Add read receipt
        let readReceipt : MessageReadReceipt = {
            messageId = messageId;
            userId = caller;
            readAt = Time.now();
        };

        let receipts = switch (messageReadReceipts.get(messageId)) {
            case (?existing) {
                // Check if user already has a read receipt for this message
                let hasReceipt = Array.find<MessageReadReceipt>(existing, func(r : MessageReadReceipt) : Bool {
                    Principal.equal(r.userId, caller)
                });
                switch (hasReceipt) {
                    case (?_) existing; // Already marked as read
                    case (null) Array.append(existing, [readReceipt]);
                };
            };
            case (null) [readReceipt];
        };

        messageReadReceipts.put(messageId, receipts);

        return #ok(());
    };

    // Mark all messages in conversation as read
    public shared ({ caller }) func markConversationAsRead(conversationId : ConversationId) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot mark conversations as read");
        };

        let messageIds = switch (conversationMessages.get(conversationId)) {
            case (?ids) ids;
            case (null) { return #err("Conversation not found or has no messages") };
        };

        for (messageId in messageIds.vals()) {
            ignore await markMessageAsRead(messageId);
        };

        // Reset unread count for this user in the conversation
        switch (conversations.get(conversationId)) {
            case (?conversation) {
                let updatedUnreadCounts = Array.map<(UserId, Nat), (UserId, Nat)>(
                    conversation.unreadCounts,
                    func((userId, count) : (UserId, Nat)) : (UserId, Nat) {
                        if (Principal.equal(userId, caller)) {
                            (userId, 0)
                        } else {
                            (userId, count)
                        }
                    }
                );

                let updatedConversation : Conversation = {
                    id = conversation.id;
                    participants = conversation.participants;
                    participantNames = conversation.participantNames;
                    createdAt = conversation.createdAt;
                    lastMessageAt = conversation.lastMessageAt;
                    lastMessage = conversation.lastMessage;
                    isGroup = conversation.isGroup;
                    title = conversation.title;
                    createdBy = conversation.createdBy;
                    isActive = conversation.isActive;
                    unreadCounts = updatedUnreadCounts;
                };
                conversations.put(conversationId, updatedConversation);
            };
            case (null) {};
        };

        return #ok(());
    };

    // Set privacy settings
    public shared ({ caller }) func setPrivacySettings(settings : PrivacySettings) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot set privacy settings");
        };

        let userSettings : PrivacySettings = {
            userId = caller;
            allowMessagesFrom = settings.allowMessagesFrom;
            allowGroupInvites = settings.allowGroupInvites;
            showOnlineStatus = settings.showOnlineStatus;
            showReadReceipts = settings.showReadReceipts;
        };

        privacySettings.put(caller, userSettings);
        return #ok(());
    };

    // Get privacy settings
    public shared query ({ caller }) func getPrivacySettings() : async Result.Result<PrivacySettings, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot access privacy settings");
        };

        switch (privacySettings.get(caller)) {
            case (?settings) #ok(settings);
            case (null) {
                // Return default settings
                let defaultSettings : PrivacySettings = {
                    userId = caller;
                    allowMessagesFrom = #followersOnly;
                    allowGroupInvites = true;
                    showOnlineStatus = true;
                    showReadReceipts = true;
                };
                #ok(defaultSettings)
            };
        };
    };

    // Edit a message
    public shared ({ caller }) func editMessage(messageId : MessageId, newContent : Text) : async Result.Result<Message, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot edit messages");
        };

        let message = switch (messages.get(messageId)) {
            case (?msg) msg;
            case (null) { return #err("Message not found") };
        };

        if (not Principal.equal(message.sender, caller)) {
            return #err("Only the sender can edit their messages");
        };

        if (Text.size(newContent) == 0) {
            return #err("Message content cannot be empty");
        };

        if (Text.size(newContent) > 2000) {
            return #err("Message content too long (max 2000 characters)");
        };

        let editedMessage : Message = {
            id = message.id;
            conversationId = message.conversationId;
            sender = message.sender;
            senderName = message.senderName;
            content = newContent;
            timestamp = message.timestamp;
            messageType = message.messageType;
            isRead = message.isRead;
            isEdited = true;
            editedAt = ?Time.now();
            replyTo = message.replyTo;
            attachments = message.attachments;
        };

        messages.put(messageId, editedMessage);
        return #ok(editedMessage);
    };

    // Delete a message
    public shared ({ caller }) func deleteMessage(messageId : MessageId) : async Result.Result<(), Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot delete messages");
        };

        let message = switch (messages.get(messageId)) {
            case (?msg) msg;
            case (null) { return #err("Message not found") };
        };

        if (not Principal.equal(message.sender, caller)) {
            return #err("Only the sender can delete their messages");
        };

        // Instead of actually deleting, mark as deleted with special content
        let deletedMessage : Message = {
            id = message.id;
            conversationId = message.conversationId;
            sender = message.sender;
            senderName = message.senderName;
            content = "[Message deleted]";
            timestamp = message.timestamp;
            messageType = #system;
            isRead = message.isRead;
            isEdited = true;
            editedAt = ?Time.now();
            replyTo = message.replyTo;
            attachments = [];
        };

        messages.put(messageId, deletedMessage);
        return #ok(());
    };

    // Get unread message count for user
    public shared query ({ caller }) func getUnreadMessageCount() : async Result.Result<Nat, Text> {
        if (Principal.isAnonymous(caller)) {
            return #err("Anonymous users cannot access unread count");
        };

        let userConvIds = switch (userConversations.get(caller)) {
            case (?convIds) convIds;
            case (null) [];
        };

        var totalUnread : Nat = 0;

        for (convId in userConvIds.vals()) {
            switch (conversations.get(convId)) {
                case (?conv) {
                    let userUnread = Array.find<(UserId, Nat)>(conv.unreadCounts, func((userId, count) : (UserId, Nat)) : Bool {
                        Principal.equal(userId, caller)
                    });
                    switch (userUnread) {
                        case (?(_, count)) totalUnread += count;
                        case (null) {};
                    };
                };
                case (null) {};
            };
        };

        return #ok(totalUnread);
    };

    // Helper functions
    private func findExistingDirectConversation(participants : [UserId]) : ?Conversation {
        if (Array.size(participants) != 2) return null;
        
        for ((_, conversation) in conversations.entries()) {
            if (not conversation.isGroup and Array.size(conversation.participants) == 2) {
                let participant1Match = Array.find<UserId>(conversation.participants, func(p : UserId) : Bool {
                    Principal.equal(p, participants[0])
                });
                let participant2Match = Array.find<UserId>(conversation.participants, func(p : UserId) : Bool {
                    Principal.equal(p, participants[1])
                });
                
                switch (participant1Match, participant2Match) {
                    case (?_, ?_) return ?conversation;
                    case (_, _) {};
                };
            };
        };
        null
    };

    private func getSenderName(sender : UserId, participants : [UserId], participantNames : [Text]) : Text {
        for (i in Iter.range(0, Array.size(participants) - 1)) {
            if (Principal.equal(participants[i], sender)) {
                if (i < Array.size(participantNames)) {
                    return participantNames[i];
                };
            };
        };
        return "Unknown";
    };

    private func updateUnreadCounts(currentCounts : [(UserId, Nat)], participants : [UserId], sender : UserId) : [(UserId, Nat)] {
        Array.map<(UserId, Nat), (UserId, Nat)>(currentCounts, func((userId, count) : (UserId, Nat)) : (UserId, Nat) {
            if (Principal.equal(userId, sender)) {
                (userId, count) // Sender's count stays the same
            } else {
                (userId, count + 1) // Increment for all other participants
            }
        })
    };
}