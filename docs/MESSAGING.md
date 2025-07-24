# 💬 Private Messaging System

The ChainedSocial messaging system provides secure, real-time private messaging capabilities built on the Internet Computer Protocol (ICP).

## Features

### Core Messaging
- **Direct Messages**: One-on-one private conversations
- **Group Chats**: Multi-participant group conversations with custom titles
- **Real-time Updates**: Messages update automatically every 30 seconds
- **Message History**: Full conversation history with pagination
- **Message Editing**: Edit your own messages after sending
- **Message Deletion**: Delete your own messages (shows as "[Message deleted]")

### Privacy & Security
- **Privacy Controls**: Configure who can send you messages
  - Everyone
  - Followers only
  - Connections only
  - Nobody (disable messaging)
- **Group Invite Controls**: Allow or disable group invitations
- **Read Receipts**: Show/hide when you've read messages
- **Online Status**: Show/hide your online status

### User Experience
- **Unread Counters**: Visual indicators for unread messages
- **Message Timestamps**: Relative timestamps (e.g., "5m ago", "Just now")
- **User Avatars**: Generated initials-based avatars
- **Emoji Support**: Built-in emoji picker
- **File Attachments**: Support for images, documents, and media files
- **Search Functionality**: Find users to start conversations with

## Architecture

### Backend (Motoko)
The messaging system is implemented as a separate canister (`messaging`) with the following key components:

#### Data Types
```motoko
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
```

#### Key Functions
- `createConversation()`: Create new direct or group conversations
- `sendMessage()`: Send messages with various types and attachments
- `getUserConversations()`: Get user's conversation list
- `getConversationMessages()`: Get paginated message history
- `markConversationAsRead()`: Mark all messages as read
- `setPrivacySettings()`: Configure messaging privacy
- `editMessage()` / `deleteMessage()`: Modify sent messages

### Frontend (React)
The frontend implements a modern chat interface with the following components:

#### Components
- **MessagingInterface**: Main chat interface with conversation sidebar and message area
- **ConversationList**: Sidebar showing user conversations with unread indicators
- **MessageList**: Chat area displaying messages with sender info and timestamps
- **MessageInput**: Input area with emoji picker and file attachment support
- **NewConversationModal**: Modal for creating new conversations with user search
- **MessagingPrivacySettings**: Modal for configuring privacy settings

#### Context Management
- **MessagingContext**: Manages messaging state, API calls, and real-time updates
- **AuthContext**: Provides authentication state and user identity

## Usage

### Starting a Conversation
1. Click the "Messages" icon in the header or navigate to `/messages`
2. Click "New" button in the messages sidebar
3. Search for users by username
4. Select participants and optionally set a group title
5. Send your first message

### Sending Messages
1. Select a conversation from the sidebar
2. Type your message in the input area
3. Use the emoji picker or attach files as needed
4. Press Enter or click the send button

### Privacy Settings
1. Open the messages interface
2. Click the privacy settings (lock) icon
3. Configure your messaging preferences:
   - Who can message you
   - Group invite permissions
   - Online status visibility
   - Read receipt visibility

### Managing Messages
- **Edit**: Hover over your own messages and click the edit icon
- **Delete**: Hover over your own messages and click the delete icon
- **Mark as Read**: Messages are automatically marked as read when viewed

## API Reference

### Messaging Canister Functions

#### Public Functions
```motoko
// Create a new conversation
createConversation(request: CreateConversationRequest) : async Result<Conversation, Text>

// Send a message
sendMessage(request: CreateMessageRequest) : async Result<Message, Text>

// Get user's conversations
getUserConversations() : async Result<[Conversation], Text>

// Get conversation messages
getConversationMessages(conversationId: ConversationId, limit: Nat, offset: Nat) : async Result<[Message], Text>

// Mark conversation as read
markConversationAsRead(conversationId: ConversationId) : async Result<(), Text>

// Privacy settings
setPrivacySettings(settings: PrivacySettings) : async Result<(), Text>
getPrivacySettings() : async Result<PrivacySettings, Text>

// Message management
editMessage(messageId: MessageId, newContent: Text) : async Result<Message, Text>
deleteMessage(messageId: MessageId) : async Result<(), Text>

// Utilities
getUnreadMessageCount() : async Result<Nat, Text>
```

### React Context API

#### MessagingContext
```javascript
const {
    // State
    conversations,
    currentConversation,
    messages,
    unreadCount,
    loading,
    error,
    privacySettings,
    
    // Actions
    sendMessage,
    createConversation,
    selectConversation,
    markConversationAsRead,
    updatePrivacySettings,
    editMessage,
    deleteMessage
} = useMessaging();
```

## Deployment

The messaging system is included in the standard deployment process:

```bash
# Deploy all canisters including messaging
just deploy

# Or deploy manually
dfx deploy messaging
dfx generate messaging
```

## Security Considerations

1. **Authentication**: All messaging functions require authenticated principals
2. **Authorization**: Users can only access their own conversations and send messages to conversations they're part of
3. **Privacy Controls**: Configurable privacy settings control who can initiate conversations
4. **Data Validation**: All inputs are validated on the backend
5. **Message Encryption**: Consider implementing end-to-end encryption for enhanced security

## Performance

- **Pagination**: Messages and conversations are paginated to handle large datasets
- **Caching**: Frontend caches conversations and messages for better performance
- **Real-time Updates**: 30-second polling interval for new messages
- **Optimistic Updates**: Local state updates immediately for better UX

## Future Enhancements

Potential improvements to consider:

1. **WebSocket Integration**: Real-time messaging without polling
2. **Message Search**: Full-text search across message history
3. **File Upload Service**: Dedicated file storage and sharing
4. **Push Notifications**: Browser/mobile notifications for new messages
5. **Message Reactions**: Emoji reactions to messages
6. **Message Threading**: Reply threads for better organization
7. **Voice/Video Calls**: Integrated calling functionality
8. **Message Encryption**: End-to-end encryption for enhanced privacy
9. **Message Scheduling**: Schedule messages to send later
10. **Auto-delete Messages**: Temporary messages that self-destruct

## Troubleshooting

### Common Issues

1. **Messages not loading**
   - Check if dfx is running
   - Verify messaging canister is deployed
   - Check browser console for errors

2. **User search not working**
   - Ensure backend canister is accessible
   - Check authentication status
   - Verify user search API is available

3. **Real-time updates not working**
   - Check network connectivity
   - Verify 30-second polling is active
   - Check for JavaScript errors

### Debug Commands
```bash
# Check canister status
dfx canister status messaging

# View canister logs
dfx canister logs messaging

# Test canister directly
dfx canister call messaging getUserConversations
```